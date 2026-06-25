# Big-O Complexity Bottlenecks

Reference guide for identifying and fixing algorithmic complexity issues in application code.

---

## Complexity Cheat Sheet

| Notation | Name | n=100 | n=10,000 | n=1,000,000 | Verdict |
|---|---|---|---|---|---|
| O(1) | Constant | 1 | 1 | 1 | Ideal |
| O(log n) | Logarithmic | 7 | 13 | 20 | Excellent |
| O(n) | Linear | 100 | 10,000 | 1,000,000 | Acceptable |
| O(n log n) | Linearithmic | 664 | 130,000 | 20,000,000 | Watch |
| O(n²) | Quadratic | 10,000 | 100,000,000 | 10¹² | Danger |
| O(2ⁿ) | Exponential | 10³⁰ | ∞ | ∞ | Never in hot paths |

**Practical rule:** O(n²) is acceptable only when n < ~500 and the operation is infrequent. Above that, it must be fixed.

---

## Quadratic Complexity (O(n²)) {#quadratic}

### Why It Matters
At n=1,000 an O(n²) algorithm does 1,000,000 operations. At n=10,000 it does 100,000,000. Most APIs serve data at this scale regularly.

### Pattern 1 — Nested Loops for Matching/Joining

```typescript
// BEFORE — O(n²): for each user, scan all permissions
const result = users.map(user => ({
  ...user,
  permissions: permissions.filter(p => p.userId === user.id)
}));
// 1000 users × 1000 permissions = 1,000,000 comparisons

// AFTER — O(n): build a Map once, look up in O(1)
const permissionsByUser = new Map<string, Permission[]>();
for (const p of permissions) {
  const existing = permissionsByUser.get(p.userId) ?? [];
  existing.push(p);
  permissionsByUser.set(p.userId, existing);
}

const result = users.map(user => ({
  ...user,
  permissions: permissionsByUser.get(user.id) ?? []
}));
// 1000 users + 1000 permissions = 2,000 operations
```

### Pattern 2 — Array.includes() / indexOf() Inside a Loop

```typescript
// BEFORE — O(n²): includes() is O(n), called n times
const filtered = items.filter(item => excludedIds.includes(item.id));

// AFTER — O(n): convert array to Set once, look up in O(1)
const excludedSet = new Set(excludedIds);
const filtered = items.filter(item => !excludedSet.has(item.id));
```

### Pattern 3 — Finding Duplicates

```typescript
// BEFORE — O(n²): for each item, scan all previous items
function findDuplicates(items: string[]): string[] {
  return items.filter((item, index) => items.indexOf(item) !== index);
}

// AFTER — O(n): use a Set
function findDuplicates(items: string[]): string[] {
  const seen = new Set<string>();
  const duplicates = new Set<string>();
  for (const item of items) {
    if (seen.has(item)) duplicates.add(item);
    else seen.add(item);
  }
  return Array.from(duplicates);
}
```

---

## Linear Search That Should Be O(1) {#linear-to-constant}

### Why It Matters
A single `Array.find()` is O(n) — fine once. But called inside a loop, or called thousands of times per request, it becomes O(n²) or O(n×m).

### Pattern — Repeated Lookups on the Same Array

```typescript
// BEFORE — O(n) per call; if called in a loop = O(n²)
function getUserById(id: string, users: User[]): User | undefined {
  return users.find(u => u.id === id);
}

// AFTER — build Map once, O(1) per lookup
const userMap = new Map(users.map(u => [u.id, u]));

function getUserById(id: string): User | undefined {
  return userMap.get(id);
}
```

### Pattern — Multiple Filters Over the Same Array

```typescript
// BEFORE — 3 full scans of the same array
const admins = users.filter(u => u.role === 'admin');
const mods = users.filter(u => u.role === 'moderator');
const banned = users.filter(u => u.status === 'banned');

// AFTER — 1 scan, grouped into a Map
const byRole = new Map<string, User[]>();
const byStatus = new Map<string, User[]>();

for (const user of users) {
  const roleGroup = byRole.get(user.role) ?? [];
  roleGroup.push(user);
  byRole.set(user.role, roleGroup);

  const statusGroup = byStatus.get(user.status) ?? [];
  statusGroup.push(user);
  byStatus.set(user.status, statusGroup);
}

const admins = byRole.get('admin') ?? [];
const mods = byRole.get('moderator') ?? [];
const banned = byStatus.get('banned') ?? [];
```

### When NOT to Optimize
Do not pre-build Maps for arrays with fewer than ~100 items that are looked up infrequently. The overhead of Map construction exceeds the benefit at tiny scales.

---

## Recursion Without Memoization {#recursion}

### Why It Matters
Naive recursive algorithms recompute the same sub-problems exponentially. `fib(40)` without memoization makes ~2.7 billion function calls. With memoization, it makes 40.

### Pattern 1 — Classic Exponential Recursion

```typescript
// BEFORE — O(2ⁿ): recomputes fib(n-1) and fib(n-2) repeatedly
function fib(n: number): number {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2);
}

// AFTER — O(n): memoize with a Map
function fib(n: number, memo = new Map<number, number>()): number {
  if (n <= 1) return n;
  if (memo.has(n)) return memo.get(n)!;
  const result = fib(n - 1, memo) + fib(n - 2, memo);
  memo.set(n, result);
  return result;
}

// BEST — O(n) iterative, O(1) space
function fib(n: number): number {
  let [a, b] = [0, 1];
  for (let i = 0; i < n; i++) [a, b] = [b, a + b];
  return a;
}
```

### Pattern 2 — Deep Tree Traversal Without Depth Guard

```typescript
// BEFORE — stack overflow on deeply nested data, no depth limit
function flattenTree(node: TreeNode): Item[] {
  return [node.value, ...node.children.flatMap(child => flattenTree(child))];
}

// AFTER — iterative BFS with explicit queue (no stack overflow risk)
function flattenTree(root: TreeNode): Item[] {
  const result: Item[] = [];
  const queue: TreeNode[] = [root];

  while (queue.length > 0) {
    const node = queue.shift()!;
    result.push(node.value);
    queue.push(...node.children);
  }

  return result;
}
```

### Pattern 3 — Recursive Permission/Role Inheritance Checks

```typescript
// BEFORE — recomputes parent chain on every permission check
function hasPermission(role: Role, permission: string): boolean {
  if (role.permissions.includes(permission)) return true;
  if (!role.parent) return false;
  return hasPermission(role.parent, permission); // re-traverses chain every check
}

// AFTER — flatten the permission set once at startup
function buildPermissionSet(role: Role): Set<string> {
  const perms = new Set<string>();
  let current: Role | null = role;
  while (current) {
    current.permissions.forEach(p => perms.add(p));
    current = current.parent;
  }
  return perms;
}

const rolePermissions = new Map(roles.map(r => [r.id, buildPermissionSet(r)]));

function hasPermission(roleId: string, permission: string): boolean {
  return rolePermissions.get(roleId)?.has(permission) ?? false; // O(1)
}
```

---

## Repeated Sorting {#repeated-sorting}

### Why It Matters
`Array.sort()` is O(n log n). Sorting 10k items on every API request adds ~50-100ms per call. Sorting on every React render causes dropped frames.

### Pattern — Re-sorting on Every Call

```typescript
// BEFORE — sorts 10k products on every search
function search(query: string, products: Product[]): Product[] {
  return products
    .sort((a, b) => b.popularity - a.popularity) // O(n log n) every call
    .filter(p => p.name.includes(query));
}

// AFTER — sort once at startup or when data changes
const sortedProducts = [...products].sort((a, b) => b.popularity - a.popularity);

function search(query: string): Product[] {
  return sortedProducts.filter(p => p.name.includes(query)); // only O(n) scan
}
```

### Pattern — Sorting Inside a Database-Backed Route

```typescript
// BEFORE — sort in application code on every request
app.get('/leaderboard', async (req, res) => {
  const scores = await db.score.findMany(); // unbounded + app-side sort
  scores.sort((a, b) => b.points - a.points);
  res.json(scores);
});

// AFTER — sort in the database (uses index), add caching
app.get('/leaderboard', async (req, res) => {
  const cached = await redis.get('leaderboard');
  if (cached) return res.json(JSON.parse(cached));

  const scores = await db.score.findMany({
    orderBy: { points: 'desc' }, // DB-side sort on indexed column
    take: 100
  });

  await redis.setEx('leaderboard', 60, JSON.stringify(scores)); // cache 60s
  res.json(scores);
});
```

### When to Pre-sort vs. DB-sort

| Scenario | Recommendation |
|---|---|
| Data comes from DB | Sort in DB with `ORDER BY` on an indexed column |
| Data is in memory, sorted once, read many times | Sort at load/startup, store sorted |
| Data changes frequently AND must be sorted | Use a sorted data structure (sorted set in Redis) |
| Small array (<100 items) sorted on demand | `Array.sort()` is fine, skip optimization |
