# Dead Code Patterns

Reference guide for detecting and safely removing dead code from any codebase.

---

## Unused Exports {#unused-exports}

### What It Is
A function, class, constant, or type that is exported from a module but is never imported by any other file in the project.

### Why It Matters
- Exported symbols create a **public API surface** — every developer assumes they are used
- They block refactoring: you cannot rename or remove them without checking all consumers
- In bundlers without tree-shaking (CommonJS), they inflate the bundle
- They create false confidence: "this function must be important, it's exported"

### How to Detect

**Manual approach (grep):**
```bash
# Find all exported names in a file
grep -E "^export (function|class|const|interface|type|enum)" src/lib/formatters.ts

# Then grep the entire project for each name
grep -rn "formatCurrency" src/ --include="*.ts" | grep -v "formatters.ts"
# If 0 results → unused export
```

**TypeScript tooling:**
```bash
# ts-prune — finds unused exports across a TypeScript project
npx ts-prune

# knip — comprehensive unused code finder
npx knip

# ESLint rule: import/no-unused-modules
# Add to .eslintrc:
# "import/no-unused-modules": ["warn", { "unusedExports": true }]
```

### Safety Checks Before Removing
1. Is the file part of a library/package distributed to external consumers? If yes, the export IS the API — do not remove without a major version bump.
2. Is the symbol used in `index.ts` barrel re-exports? Check the barrel too.
3. Is it used in tests only? Tests are valid consumers.

### Safe Removal Steps
1. Search the entire codebase (including `node_modules` excluded) for the name
2. Confirm zero non-self references
3. Remove the `export` keyword first — if TypeScript/ESLint reports no errors, the function itself can go next
4. If the function is also unused internally after removing `export`, delete the whole declaration

---

## Unreachable Code {#unreachable-code}

### What It Is
Code that appears in the same block after a statement that unconditionally transfers control flow away (`return`, `throw`, `break`, `continue`). The JavaScript/TypeScript engine will never reach these lines.

### Categories

**Category 1 — After unconditional return/throw:**
```typescript
function validate(input: string): boolean {
  if (!input) {
    return false;
    console.log('Input was empty'); // UNREACHABLE — after return
  }
  return true;
  doCleanup(); // UNREACHABLE — after return
}
```

**Category 2 — Constant condition (always true/false):**
```typescript
const DEBUG_MODE = false;
if (DEBUG_MODE) {
  runDiagnostics(); // UNREACHABLE — condition is always false
}

if (true) {
  newPath();
} else {
  oldPath(); // UNREACHABLE — else never runs
}
```

**Category 3 — Type narrowing makes branch impossible:**
```typescript
function process(status: 'active' | 'inactive') {
  if (status === 'active') return handleActive();
  if (status === 'inactive') return handleInactive();
  // TypeScript knows this is unreachable — status has no other values
  legacyFallback(); // UNREACHABLE
}
```

**Category 4 — Loop with immediate break/return:**
```typescript
while (true) {
  return result;
  processNext(); // UNREACHABLE — return exits before this
}
```

### Detection Tools
```bash
# TypeScript — enable strict checks that surface some unreachable code
# tsconfig.json: "allowUnreachableCode": false

# ESLint rules
# "no-unreachable": "error"
# "no-constant-condition": "error"
```

### Safe to Remove?
Yes — unreachable code is **guaranteed** to never run. Removing it cannot change behavior. If removing it reveals that the code was intended to run (e.g., a misplaced `return`), that is a bug to fix, not a reason to keep the dead code.

---

## Zombie Routes {#zombie-routes}

### What It Is
An HTTP route registered in the router that is broken in one of these ways:
- The handler function does not exist (reference error on startup or request)
- The handler module was deleted but the route definition remains
- A duplicate route definition that is shadowed by another route registered later
- A route for a feature that was fully removed but the route registration was not cleaned up

### Detection Strategy

**Step 1 — List all route definitions:**
```bash
# Express routes
grep -rn "router\.\(get\|post\|put\|patch\|delete\)" src/ --include="*.ts"
grep -rn "app\.\(get\|post\|put\|patch\|delete\)" src/ --include="*.ts"

# NestJS controllers
grep -rn "@\(Get\|Post\|Put\|Patch\|Delete\)" src/ --include="*.ts"
```

**Step 2 — Verify each handler exists:**
```typescript
// Route definition:
router.get('/reports/legacy', legacyReportController.getAll);

// Check: does legacyReportController exist?
// Check: does legacyReportController.getAll exist as a method?
// Check: is legacyReportController imported at the top of the file?
```

**Step 3 — Check for duplicate paths:**
```typescript
// PROBLEM — two handlers for the same path/method; first is zombie
router.post('/api/users', oldUserController.create);   // never called
router.post('/api/users', newUserController.create);   // Express uses this one
```

### Common Causes
- Controller was deleted but route file was not updated
- Feature branch merged with incomplete cleanup
- API versioning done by adding new routes without removing old ones
- Copy-paste of route files without updating handler references

### Fix
1. Delete the route definition
2. If the controller still has other methods used elsewhere, only remove the unused method
3. Run the test suite — a zombie route deletion should have zero failing tests (since the route was never working)

---

## Unused Dependencies {#unused-dependencies}

### What It Is
A package listed in `package.json` (`dependencies`, `devDependencies`, or `peerDependencies`) that is never imported or required in any source, test, or config file.

### Detection Strategy

**Automated:**
```bash
# depcheck — most reliable for Node.js
npx depcheck

# knip — also detects unused deps
npx knip

# npm-check — shows unused, missing, and outdated packages
npx npm-check
```

**Manual grep approach:**
```bash
# For each package in package.json, search source for its import
grep -rn "from 'moment'" src/ --include="*.ts"
grep -rn "require('moment')" src/ --include="*.ts"
# If 0 results → likely unused (check config files and dynamic requires too)
```

### High-Value Targets (Commonly Orphaned)

| Package | Size | Common Replacement |
|---|---|---|
| `moment` | ~547KB | `date-fns` (tree-shakeable) or native `Intl` |
| `lodash` | ~70KB | Native array methods (`map`, `filter`, `reduce`) |
| `request` | deprecated | `axios`, `node-fetch`, or native `fetch` |
| `bluebird` | ~80KB | Native `Promise` (Node.js 10+) |
| `underscore` | ~50KB | Native array methods |
| `jquery` | ~90KB | Native DOM APIs |
| `async` | ~25KB | Native `async/await`, `Promise.all` |

### Safety Before Removing
- Check `scripts` in `package.json` — some packages are only used in npm scripts
- Check config files (`webpack.config.js`, `.babelrc`, `jest.config.js`) — build tools are often indirect
- Check `require()` with dynamic strings: `require(\`./plugins/${name}\`)` — static analysis misses these
- Run the full test suite after removal to catch runtime dependency surprises

### Removal Command
```bash
npm uninstall moment lodash xml2js
# or
yarn remove moment lodash xml2js
# or (Python)
pip uninstall requests-old-wrapper
```

---

## Orphaned Test Files {#orphaned-tests}

### What It Is
A test file (`.spec.ts`, `.test.ts`, `.spec.js`, `_test.py`, `Test*.java`) that imports or references a source module that no longer exists — because the source was renamed, moved, or deleted.

### Why It Matters
- Causes `Module not found` errors in CI
- Inflates test count — orphaned tests count toward "coverage" but test nothing
- Misleads the team into thinking a module is tested when it no longer exists

### Detection Strategy

**For TypeScript/JavaScript:**
```bash
# Find all imports in test files
grep -rn "^import" src/ --include="*.spec.ts" --include="*.test.ts"

# For each import path, verify the file exists:
ls src/payments/old-payment.service.ts
# → No such file → orphaned test
```

**Automated:**
```bash
# TypeScript compilation catches most of these
npx tsc --noEmit

# Jest with --passWithNoTests will hide them — run without that flag
npx jest --no-coverage 2>&1 | grep "Cannot find module"
```

### Fix
1. If the source module was renamed/moved: update the import path in the test
2. If the source module was deleted: evaluate whether the test covers behavior now handled elsewhere
3. If the test is truly orphaned: delete the test file

---

## Feature Flag Dead Branches {#feature-flags}

### What It Is
A feature flag conditional where the flag value is effectively constant — either a hardcoded literal or an environment variable that has the same value in all environments — making one branch permanently unreachable.

### Categories

**Category 1 — Hardcoded constant:**
```typescript
const USE_NEW_CHECKOUT = true; // was a flag during migration, now always true

if (USE_NEW_CHECKOUT) {
  return newCheckoutFlow(); // always executes
} else {
  return legacyCheckoutFlow(); // dead branch — never executes
}
```

**Category 2 — Environment variable always set to same value:**
```typescript
// .env.development, .env.staging, .env.production all have:
// ENABLE_NEW_UI=true

if (process.env.ENABLE_NEW_UI === 'true') {
  return NewUI; // always renders
} else {
  return OldUI; // permanently dead
}
```

**Category 3 — Flag removed from feature flag service but condition remains:**
```typescript
if (featureFlags.isEnabled('old-beta-feature')) { // flag was deleted from service
  return betaFeature(); // service always returns false for deleted flags
}
```

### How to Detect
1. Search for boolean constants set to `true` or `false` that are only used in conditionals
2. Check feature flag service configuration — are any flags missing from the registry?
3. Check `.env` files — find flags that are identical across all environments

### Safe Removal Steps
1. Confirm with the team that the flag migration is complete and the flag will not be toggled off
2. Inline the live branch: replace the entire `if/else` with just the body of the live branch
3. Remove the flag constant, environment variable, and any feature flag service registration
4. Delete the dead branch's code if it is not used elsewhere
