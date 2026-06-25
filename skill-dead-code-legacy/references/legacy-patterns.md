# Legacy Patterns Reference

Reference guide for identifying and migrating deprecated APIs, outdated language idioms, and obsolete dependencies.

---

## Deprecated APIs {#deprecated-apis}

### React Deprecated and Removed APIs

#### Lifecycle Methods Removed in React 18+

| Deprecated | Replacement | Removed in |
|---|---|---|
| `componentWillMount` | `componentDidMount` or `useEffect(() => {}, [])` | React 17 (strict) / 18 |
| `componentWillReceiveProps` | `getDerivedStateFromProps` or `useEffect` with deps | React 17 (strict) / 18 |
| `componentWillUpdate` | `getSnapshotBeforeUpdate` or `useEffect` | React 17 (strict) / 18 |

**Migration:**
```tsx
// BEFORE — componentWillMount
class UserProfile extends React.Component {
  componentWillMount() {
    this.fetchUser(this.props.userId);
  }
}

// AFTER — componentDidMount
class UserProfile extends React.Component {
  componentDidMount() {
    this.fetchUser(this.props.userId);
  }
}

// MODERN — functional component with useEffect
function UserProfile({ userId }) {
  useEffect(() => {
    fetchUser(userId);
  }, [userId]);
}
```

#### ReactDOM.render (Removed in React 18)

```tsx
// BEFORE — React 17 and earlier
import ReactDOM from 'react-dom';
ReactDOM.render(<App />, document.getElementById('root'));

// AFTER — React 18+
import { createRoot } from 'react-dom/client';
const root = createRoot(document.getElementById('root')!);
root.render(<App />);
```

#### String Refs (Removed in React 19)

```tsx
// BEFORE — string ref (deprecated since React 16)
class MyInput extends React.Component {
  handleFocus() {
    this.refs.myInput.focus(); // string ref
  }
  render() {
    return <input ref="myInput" />;
  }
}

// AFTER — createRef or useRef
class MyInput extends React.Component {
  inputRef = React.createRef<HTMLInputElement>();
  handleFocus() {
    this.inputRef.current?.focus();
  }
  render() {
    return <input ref={this.inputRef} />;
  }
}
```

---

### Node.js Deprecated APIs

| Deprecated API | Replacement | Deprecated Since |
|---|---|---|
| `new Buffer(size)` | `Buffer.alloc(size)` | Node.js 6 |
| `new Buffer(string)` | `Buffer.from(string)` | Node.js 6 |
| `crypto.createCipher` | `crypto.createCipheriv` | Node.js 10 |
| `url.parse()` | `new URL(string)` | Node.js 11 |
| `process.binding()` | Internal — do not use | Multiple versions |
| `fs.exists()` | `fs.access()` or `fs.existsSync()` | Node.js 1 |

**Migration examples:**
```javascript
// BEFORE
const buf = new Buffer(256);
const parsed = require('url').parse('https://example.com/path?q=1');

// AFTER
const buf = Buffer.alloc(256);
const parsed = new URL('https://example.com/path?q=1');
console.log(parsed.searchParams.get('q')); // '1'
```

---

### Express Deprecated APIs

```javascript
// BEFORE — Express 3 / early Express 4
app.configure(function() { ... }); // removed in Express 4
res.send(404); // status-only send — removed in Express 4
res.json(500, { error: 'msg' }); // status as first arg — removed in Express 4

// AFTER — Express 4+
app.use(middleware); // configure middleware directly
res.status(404).send('Not Found');
res.status(500).json({ error: 'msg' });
```

---

## Outdated Dependencies {#outdated-deps}

### How to Assess Dependency Age

**npm:**
```bash
# Show all outdated packages with current, wanted, and latest versions
npm outdated

# Show security vulnerabilities
npm audit

# Check a specific package's release history
npm view moment time --json | tail -5
```

**Python:**
```bash
pip list --outdated
pip-audit  # security vulnerabilities
```

### Risk Matrix

| Gap | Risk Level | Action |
|---|---|---|
| 1 patch version behind | Low | Update in next sprint |
| 1 minor version behind | Low-Medium | Update in next sprint |
| 1 major version behind | Medium | Plan upgrade, review changelog |
| 2+ major versions behind | High | Immediate upgrade planning required |
| Known CVE | Critical | Fix in current sprint |
| Package deprecated | High | Replace with maintained alternative |

### High-Priority Packages to Check

**JavaScript/Node.js:**
```
request          → deprecated (maintainer abandoned) → use axios or native fetch
node-uuid        → deprecated → use crypto.randomUUID() (Node.js 14.17+) or uuid v9+
jade             → deprecated → use pug (official rename)
grunt            → often outdated → evaluate vs. vite/esbuild/webpack 5
bower            → deprecated → use npm/yarn workspaces
tslint           → deprecated → use @typescript-eslint/eslint-plugin
```

**Python:**
```
Flask < 2.0     → major security improvements in 2.x and 3.x
Django < 4.0    → LTS ended; missing security patches
PyYAML < 6.0    → arbitrary code execution via yaml.load() without Loader
Pillow < 10.0   → multiple CVEs in older versions
```

### Checking for Abandoned Packages
Signs a package is abandoned (check npm/PyPI page):
- Last publish date > 2 years ago
- Open issues/PRs with no maintainer response
- `npm info <package>` shows `deprecated` field
- GitHub repo archived or "unmaintained" warning in README

---

## Old Language Idioms {#old-idioms}

### JavaScript / TypeScript

#### `var` vs `const` / `let`

```javascript
// BEFORE — var has function scope and hoisting, causing subtle bugs
var userId = req.params.id;
var result;
for (var i = 0; i < items.length; i++) {
  result = items[i];
}

// AFTER — const for values that don't change, let for reassigned variables
const userId = req.params.id;
let result;
for (let i = 0; i < items.length; i++) {
  result = items[i];
}
```

**Why `var` is problematic:**
```javascript
// var is hoisted to function scope — this doesn't throw, it logs undefined
console.log(x); // undefined (not ReferenceError)
var x = 5;

// var in a for loop leaks the counter
for (var i = 0; i < 3; i++) {}
console.log(i); // 3 — i still exists after the loop
```

#### Callback Hell vs Async/Await

```javascript
// BEFORE — nested callbacks (callback hell)
getUser(userId, function(err, user) {
  if (err) return callback(err);
  getOrders(user.id, function(err, orders) {
    if (err) return callback(err);
    getProducts(orders, function(err, products) {
      if (err) return callback(err);
      callback(null, { user, orders, products });
    });
  });
});

// AFTER — async/await (flat, readable, debuggable)
async function getUserData(userId) {
  const user = await getUser(userId);
  const orders = await getOrders(user.id);
  const products = await getProducts(orders);
  return { user, orders, products };
}
```

#### `.then()/.catch()` Mixed With `async/await`

```typescript
// BEFORE — mixed paradigms, redundant .then()
async function getUser(id: string) {
  return db.user.findUnique({ where: { id } })
    .then(user => user)         // redundant — async function already returns the promise
    .catch(err => { throw err; }); // redundant — unhandled rejection propagates anyway
}

// AFTER — pure async/await
async function getUser(id: string) {
  return db.user.findUnique({ where: { id } });
}
```

#### `require()` Mixed With `import`

```javascript
// BEFORE — mixed module systems in a TypeScript/ESM project
import express from 'express';
const path = require('path');        // CommonJS in an ESM file
const { readFile } = require('fs'); // should be: import { readFile } from 'fs/promises'

// AFTER — consistent ESM imports
import express from 'express';
import path from 'path';
import { readFile } from 'fs/promises';
```

#### String Concatenation vs Template Literals

```javascript
// BEFORE — hard to read, easy to miss spaces
const message = 'Hello ' + user.name + ', you have ' + count + ' messages.';
const url = 'https://' + host + '/api/v' + version + '/users/' + userId;

// AFTER — template literals
const message = `Hello ${user.name}, you have ${count} messages.`;
const url = `https://${host}/api/v${version}/users/${userId}`;
```

#### Object/Array Patterns

```javascript
// BEFORE — verbose object/array manipulation
var keys = Object.keys(obj);
var values = [];
for (var i = 0; i < keys.length; i++) {
  values.push(obj[keys[i]]);
}

// AFTER — modern idioms
const values = Object.values(obj);

// BEFORE — manual object merge
var merged = {};
for (var key in obj1) merged[key] = obj1[key];
for (var key in obj2) merged[key] = obj2[key];

// AFTER — spread
const merged = { ...obj1, ...obj2 };
```

---

### Python

#### Python 2 Idioms in a Python 3 Codebase

```python
# BEFORE — Python 2 print statement
print "Hello, World!"
print "Error:", err

# AFTER — Python 3 print function
print("Hello, World!")
print("Error:", err)

# BEFORE — Python 2 integer division
result = 5 / 2  # gives 2 in Python 2, 2.5 in Python 3

# AFTER — explicit floor division when integer is intended
result = 5 // 2  # explicit floor division: 2
result = 5 / 2   # true division in Python 3: 2.5

# BEFORE — Python 2 unicode prefix (redundant in Python 3)
name = u"María"
data = b"binary"  # bytes prefix still valid and useful in Python 3

# AFTER — Python 3 (all strings are unicode by default)
name = "María"

# BEFORE — Python 2 dict.iteritems(), iterkeys(), itervalues()
for key, value in my_dict.iteritems():
    print key, value

# AFTER — Python 3
for key, value in my_dict.items():
    print(key, value)

# BEFORE — Python 2 xrange (does not exist in Python 3)
for i in xrange(1000):
    process(i)

# AFTER — Python 3 range (lazy by default)
for i in range(1000):
    process(i)
```

#### Old Exception Syntax

```python
# BEFORE — Python 2 exception syntax
try:
    risky()
except ValueError, e:  # old syntax — SyntaxError in Python 3
    handle(e)

# AFTER — Python 3
try:
    risky()
except ValueError as e:
    handle(e)
```

#### Old String Formatting

```python
# BEFORE — % formatting (still works, but inconsistent with f-strings)
message = "Hello %s, you have %d messages" % (name, count)
url = "/api/users/%s/orders/%d" % (user_id, order_id)

# AFTER — f-strings (Python 3.6+, readable and fast)
message = f"Hello {name}, you have {count} messages"
url = f"/api/users/{user_id}/orders/{order_id}"
```
