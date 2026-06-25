---
name: skill-performance-audit
description: >-
  Performance bottleneck detector for any codebase.
  Scans backend, frontend, database, and connection layers for N+1 queries,
  blocking I/O, missing indexes, render thrashing, bundle bloat, pool exhaustion,
  Big-O complexity issues, and over-engineering anti-patterns.
  Produces a severity-ranked audit report with actionable quick wins.
compatibility: Framework agnostic. Works with Node.js, Python, Java, PHP, React, Vue, Next.js, Prisma, TypeORM, Mongoose, raw SQL.
metadata:
  author: leifermendez
  version: "1.1"
  tags: "performance, audit, bottleneck, n+1, optimization, caching, indexing, frontend, backend, database, connection-pool, big-o, complexity, over-engineering"
---

## Overview

This skill performs a systematic performance audit of any codebase. When invoked, it scans backend API code, database schemas, ORM queries, frontend components, and connection pool configuration for observable performance anti-patterns. It produces a severity-ranked audit report with before/after code fixes for the top bottlenecks found.

**Trigger phrases:** "audit performance", "find bottlenecks", "why is this slow", "performance review", "optimize this codebase", "check N+1 queries", "missing indexes".

## Parameters

The agent requires access to the project's source files. Before starting the scan, confirm:

| Input | Required | Description |
|---|---|---|
| Project source directory | Yes | The root path or `src/` folder to scan |
| Framework / stack | Auto-detected | Detected from `package.json`, config files, file extensions |
| Scope | Optional | Limit scan to backend, frontend, or database only |

If no project path is provided, ask the user to specify the directory or share the relevant files.

## Returns

This skill produces a structured **Performance Audit Report** containing:
- Stack detected (backend, frontend, database)
- Severity-ranked findings: CRITICAL / WARNING / NOTICE
- For each finding: file path, line number, pattern description, and performance impact
- Top 3 Quick Wins with before/after code snippets

## Error Handling

| Situation | Action |
|---|---|
| No source files found | Ask the user to confirm the project path; check for non-standard source directories |
| Unsupported language/framework | Report which checks are unsupported; run applicable checks only |
| File too large to read fully | Sample the file and note that a partial scan was performed |
| No bottlenecks found | Report "No issues found in scanned scope" — do not fabricate findings |

---

## Core Philosophy: Find Real Bottlenecks, Not Hypothetical Ones

This skill audits **observable code patterns** that are proven to cause production slowdowns. It does NOT recommend speculative micro-optimizations or premature abstractions.

### What We Audit

- **Backend & API** — blocking I/O, missing pagination, absent caching, N+1 queries
- **Database Connections** — pool exhaustion, connection leaks, missing timeouts, long transactions
- **Database / ORM** — missing indexes, over-fetching, unbounded queries
- **Big-O Complexity** — quadratic loops, linear searches replaceable with O(1) Maps/Sets, exponential recursion, repeated sorting
- **Frontend** — render thrashing, bundle bloat, missing lazy loading, unoptimized assets
- **Over-Engineering** — empty pass-through layers, premature generalization, unnecessary infrastructure, unjustified design patterns

### What We Do NOT Do

- Recommend rewrites of working code without evidence
- Flag code that "might" be slow without a clear anti-pattern
- Suggest caching where traffic data is unknown
- Report style issues as performance issues

---

## Step 1 — Context Discovery

Before scanning, identify the project's stack to apply the correct checks.

### Detect Backend
Look for these signals:

| Signal | Framework/Runtime |
|---|---|
| `express`, `fastify` in `package.json` | Node.js / Express / Fastify |
| `@nestjs/core` in `package.json` | NestJS |
| `requirements.txt` with `django` or `flask` | Python |
| `pom.xml` or `build.gradle` | Java / Spring |
| `Gemfile` with `rails` | Ruby on Rails |

### Detect Frontend
Look for these signals:

| Signal | Framework |
|---|---|
| `react`, `react-dom` in `package.json` | React |
| `next` in `package.json` | Next.js |
| `vue` in `package.json` | Vue.js |
| `@angular/core` in `package.json` | Angular |

### Detect Database / ORM
Look for these signals:

| Signal | ORM / DB |
|---|---|
| `schema.prisma` file present | Prisma |
| `@Entity` or `typeorm` in code | TypeORM |
| `mongoose` in `package.json` | Mongoose / MongoDB |
| `.sql` files or raw `pg`, `mysql2` in `package.json` | Raw SQL |

Capture the full stack before proceeding. Skip checks that are irrelevant to the detected stack.

---

## Step 2 — The Bottleneck Scan

Run these checks in order. For each finding, note the file path and line numbers.

### BACKEND CHECKS

#### B1 — N+1 Queries
**Pattern:** A database call inside a loop (`for`, `while`, `forEach`, `map`, `Promise.all` over individual queries).

**What to look for:**
```typescript
// PROBLEM — fires one query per item
for (const userId of userIds) {
  const user = await db.user.findUnique({ where: { id: userId } });
}

// ALSO PROBLEM — Promise.all with individual queries is still N+1
await Promise.all(userIds.map(id => db.user.findUnique({ where: { id } })));
```

**Severity:** CRITICAL — on large datasets, this converts O(1) endpoints into O(n) database hammers.

**Fix reference:** `references/backend-bottlenecks.md#n-plus-one`

---

#### B2 — Synchronous Blocking in Request Handlers
**Pattern:** Synchronous file system, crypto, or compression calls inside HTTP route handlers.

**What to look for:**
```typescript
// PROBLEM — blocks the entire Node.js event loop
app.get('/data', (req, res) => {
  const content = fs.readFileSync('./large-file.json');       // BLOCKING
  const hash = crypto.createHash('md5').update(data).digest('hex');  // OK for small data
  const compressed = zlib.gzipSync(largeBuffer);              // BLOCKING
});
```

**Severity:** CRITICAL — a single synchronous call blocks ALL concurrent requests.

**Fix reference:** `references/backend-bottlenecks.md#sync-blocking`

---

#### B3 — Unpaginated Endpoints
**Pattern:** Queries that return all records without a `limit`, `take`, or pagination parameter.

**What to look for:**
```typescript
// PROBLEM — returns every row, always
const users = await db.user.findMany();
const orders = await Order.find({});
const results = await db.query('SELECT * FROM products');
```

**Severity:** WARNING — harmless in dev, catastrophic in production with 100k+ rows.

**Fix reference:** `references/backend-bottlenecks.md#pagination`

---

#### B4 — Missing Caching on Expensive Operations
**Pattern:** Identical external API calls or heavy computations re-executed on every request with no cache layer.

**What to look for:**
- External API calls (`axios.get`, `fetch`) inside route handlers with no cache check
- CPU-heavy transforms (sorting, aggregating large arrays) inside hot paths
- No Redis, in-memory Map, or HTTP cache headers on read-heavy endpoints

**Severity:** WARNING — depends on traffic; becomes CRITICAL under load.

**Fix reference:** `references/backend-bottlenecks.md#caching`

---

#### B5 — Unhandled Promise Rejections / Missing Error Boundaries
**Pattern:** `async` functions without `try/catch` that can crash the process silently.

**What to look for:**
```typescript
// PROBLEM — unhandled rejection crashes Node.js process
app.get('/user/:id', async (req, res) => {
  const user = await db.user.findUnique({ where: { id: req.params.id } }); // no try/catch
  res.json(user);
});
```

**Severity:** WARNING — causes silent 500s and potential memory leaks from dangling promises.

---

### CONNECTION CHECKS

#### C1 — Connection Pool Exhaustion
**Pattern:** More concurrent requests than available database connections. New requests hang waiting for a connection to free up, causing cascading timeouts.

**What to look for:**
- Pool size not configured (uses ORM defaults, often too small for production)
- Long-running queries or transactions holding connections open unnecessarily
- No connection timeout configured (requests queue forever)

```typescript
// PROBLEM — default Prisma pool is usually 5 connections; may be too small
const db = new PrismaClient();

// PROBLEM — TypeORM default pool of 10 is often not reviewed
createConnection({ type: 'postgres', ... }); // no pool config

// PROBLEM — creating a new pool/client per request instead of sharing one
app.get('/users', async (req, res) => {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL }); // new pool every request!
  const result = await pool.query('SELECT * FROM users');
});
```

**Severity:** CRITICAL — under load, a pool of 5 with 100 concurrent requests means 95 requests stall and time out.

**Fix reference:** `references/connection-bottlenecks.md#pool-exhaustion`

---

#### C2 — Connection Leaks (Not Releasing Connections)
**Pattern:** Connections acquired from the pool that are never released back — because of an unhandled error, early return, or missing `finally` block.

**What to look for:**
```typescript
// PROBLEM — if query throws, client is never released back to pool
const client = await pool.connect();
const result = await client.query('SELECT ...'); // throws → client leaked
client.release();

// PROBLEM — TypeORM QueryRunner not released in error path
const qr = dataSource.createQueryRunner();
await qr.connect();
await qr.startTransaction();
await qr.manager.save(entity); // if throws, release() is never called
await qr.commitTransaction();
await qr.release();
```

**Severity:** CRITICAL — each leaked connection permanently reduces pool capacity. Under load, pool empties completely and all requests hang.

**Fix reference:** `references/connection-bottlenecks.md#connection-leaks`

---

#### C3 — Missing Connection Timeout Configuration
**Pattern:** No `connectionTimeoutMillis`, `acquireTimeoutMillis`, or equivalent configured — so requests wait indefinitely for a pool slot instead of failing fast.

**What to look for:**
```typescript
// PROBLEM — no timeout; requests queue forever if pool is full
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// PROBLEM — Prisma without connection limit or timeout hints
const db = new PrismaClient();
// Should use: DATABASE_URL="...?connection_limit=10&pool_timeout=10"
```

**Severity:** WARNING — without timeouts, a DB slowdown causes all API requests to hang until the server runs out of memory.

**Fix reference:** `references/connection-bottlenecks.md#timeouts`

---

#### C4 — Long Transactions Blocking Other Queries
**Pattern:** A transaction that holds locks for too long — because it includes slow external calls, large batch operations, or is never committed.

**What to look for:**
```typescript
// PROBLEM — HTTP call inside a transaction holds DB lock for network RTT
await db.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id } });
  const response = await fetch('https://external-api.com/validate'); // holds lock during HTTP call
  await tx.user.update({ where: { id }, data: { verified: true } });
});

// PROBLEM — large batch loop inside a single transaction
await db.$transaction(async (tx) => {
  for (const item of tenThousandItems) {
    await tx.item.create({ data: item }); // locks table for entire duration
  }
});
```

**Severity:** WARNING — long locks block concurrent writes/reads on affected rows, causing request pile-ups.

**Fix reference:** `references/connection-bottlenecks.md#long-transactions`

---

### DATABASE CHECKS

#### D1 — Missing Indexes on Frequently Queried Fields
**Pattern:** Fields used in `WHERE`, `JOIN`, or `ORDER BY` clauses that lack `@index`, `@unique`, or explicit index declarations.

**What to look for in Prisma schema:**
```prisma
model User {
  id        String   @id
  email     String   // PROBLEM — no @unique or @@index; queried constantly
  createdAt DateTime // PROBLEM — if used in ORDER BY, needs an index
}
```

**What to look for in TypeORM:**
```typescript
@Column()
email: string; // PROBLEM — missing @Index() decorator
```

**Severity:** CRITICAL on tables > 10k rows. Full table scans grow with O(n) complexity.

**Fix reference:** `references/database-bottlenecks.md#missing-indexes`

---

#### D2 — Over-Fetching (SELECT *)
**Pattern:** Queries that pull all columns when only a subset is needed.

**What to look for:**
```typescript
// PROBLEM — pulls blob columns, unused fields, everything
const user = await db.user.findUnique({ where: { id } });
// vs. select only what's needed
const user = await db.user.findUnique({ where: { id }, select: { id: true, email: true } });
```

**Severity:** WARNING — especially costly when tables have `TEXT`, `JSON`, or `BLOB` columns.

**Fix reference:** `references/database-bottlenecks.md#over-fetching`

---

#### D3 — Missing Transactions for Multi-Step Writes
**Pattern:** Multiple related write operations performed without a database transaction, leaving the system in an inconsistent state on partial failure.

**What to look for:**
```typescript
// PROBLEM — if second write fails, first write is orphaned
await db.order.create({ data: orderData });
await db.inventory.update({ ... }); // if this throws, order exists with no inventory deduction
```

**Severity:** WARNING — data integrity risk that becomes CRITICAL in financial or inventory systems.

---

### BIG-O COMPLEXITY CHECKS

These checks identify **algorithmic complexity** issues — patterns where the time or space cost of an operation scales poorly as input size grows. Each finding includes the detected complexity class and the practical breaking point.

#### O1 — Nested Loops Over the Same Dataset (O(n²))
**Pattern:** A loop inside a loop over collections of the same or related data. Performance degrades quadratically: doubling the input quadruples the time.

**What to look for:**
```typescript
// PROBLEM — O(n²): for each user, scan all permissions
for (const user of users) {
  for (const permission of permissions) {
    if (permission.userId === user.id) { // should use a Map lookup instead
      user.perms.push(permission);
    }
  }
}

// PROBLEM — O(n²): Array.includes() inside a loop (includes is O(n) itself)
const filtered = items.filter(item => excludedIds.includes(item.id));

// PROBLEM — O(n²): indexOf inside a loop
for (const item of largeArray) {
  if (anotherLargeArray.indexOf(item.id) !== -1) { ... }
}
```

**Severity:** CRITICAL when n > 1,000. At n=10,000: O(n) = 10k ops, O(n²) = 100M ops.

**Fix reference:** `references/complexity-bigO.md#quadratic`

---

#### O2 — Linear Search on Large Collections That Could Be O(1) (O(n) → O(1))
**Pattern:** Using `Array.find()`, `Array.filter()`, or `Array.includes()` repeatedly on the same large array, when the array should be converted to a `Map` or `Set` once for O(1) lookups.

**What to look for:**
```typescript
// PROBLEM — O(n) per lookup, called in a loop = O(n²) total
function getUser(id: string) {
  return users.find(u => u.id === id); // scans array every call
}

// PROBLEM — repeated filter on same array
const admins = users.filter(u => u.role === 'admin');
const mods = users.filter(u => u.role === 'mod'); // second full scan
```

**Severity:** WARNING — becomes CRITICAL when called inside loops or hot paths.

**Fix reference:** `references/complexity-bigO.md#linear-to-constant`

---

#### O3 — Uncontrolled Recursion Without Memoization (Exponential Risk)
**Pattern:** Recursive functions that recompute the same sub-problems without caching results — or that lack a proper base case / depth limit.

**What to look for:**
```typescript
// PROBLEM — O(2ⁿ) without memoization: recomputes fib(n-1) and fib(n-2) from scratch
function fib(n: number): number {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2); // exponential time
}

// PROBLEM — recursive tree traversal with no depth guard
function flatten(node: TreeNode): Item[] {
  return [node.value, ...node.children.flatMap(flatten)]; // no depth limit
}
```

**Severity:** CRITICAL if called with unbounded input. `fib(50)` makes ~2²⁵ calls (~33M).

**Fix reference:** `references/complexity-bigO.md#recursion`

---

#### O4 — Repeated Sorting of the Same Data (O(n log n) wasted)
**Pattern:** Sorting the same array on every function call, request, or render cycle instead of sorting once and caching or maintaining a sorted structure.

**What to look for:**
```typescript
// PROBLEM — sorts entire product list on every search keystroke
function search(query: string) {
  const sorted = products.sort((a, b) => b.price - a.price); // re-sort every call
  return sorted.filter(p => p.name.includes(query));
}

// PROBLEM — sorting inside a route handler with no cache
app.get('/leaderboard', async (req, res) => {
  const scores = await db.score.findMany();
  scores.sort((a, b) => b.points - a.points); // sorted fresh every request
  res.json(scores);
});
```

**Severity:** WARNING — at 10k records, sort is ~130k comparisons. In a hot path this adds up fast.

**Fix reference:** `references/complexity-bigO.md#repeated-sorting`

---

### FRONTEND CHECKS

#### F1 — Expensive Computations Without Memoization
**Pattern:** Heavy calculations or array transforms inside React/Vue component render functions that re-run on every render.

**What to look for:**
```tsx
// PROBLEM — re-sorts 10k items on every keystroke, mouse move, etc.
function ProductList({ products }) {
  const sorted = products.sort((a, b) => b.price - a.price); // re-runs every render
  return <ul>{sorted.map(p => <li key={p.id}>{p.name}</li>)}</ul>;
}
```

**Severity:** WARNING — causes dropped frames and janky UI on low-end devices.

**Fix reference:** `references/frontend-bottlenecks.md#memoization`

---

#### F2 — Missing Lazy Loading for Heavy Components
**Pattern:** Large components (charts, maps, rich text editors, modals) imported synchronously at the top of the file, bloating the initial bundle.

**What to look for:**
```tsx
// PROBLEM — Chart.js is ~200KB and is loaded even for users who never see the chart
import { Chart } from 'chart.js';
import ReactQuill from 'react-quill'; // rich text editor, large bundle
```

**Severity:** WARNING — directly increases Time to Interactive (TTI) for all users.

**Fix reference:** `references/frontend-bottlenecks.md#lazy-loading`

---

#### F3 — Unoptimized Images
**Pattern:** Raw `<img>` tags with large static images, no width/height hints, no lazy loading, or no modern format (WebP/AVIF).

**What to look for:**
```tsx
// PROBLEM — in a Next.js project, bypasses all optimization
<img src="/hero.jpg" />

// ALSO PROBLEM — no lazy loading on below-the-fold images
<img src="/product.png" loading="eager" />
```

**Severity:** WARNING — images are typically 60-80% of page weight. Critical for LCP score.

**Fix reference:** `references/frontend-bottlenecks.md#images`

---

#### F4 — Bundle Bloat from Whole-Library Imports
**Pattern:** Importing an entire library when only a single function or component is needed.

**What to look for:**
```tsx
// PROBLEM — imports all 200+ lodash functions (~70KB gzipped)
import _ from 'lodash';
const result = _.groupBy(items, 'category');

// PROBLEM — imports all of date-fns
import * as dateFns from 'date-fns';
```

**Severity:** WARNING — inflates JavaScript bundle size, hurting TTI for all users.

**Fix reference:** `references/frontend-bottlenecks.md#bundle-bloat`

---

#### F5 — Prop Drilling / Context Overuse Causing Full-Tree Re-renders
**Pattern:** React Context used to share frequently-updating state (e.g., scroll position, form input) causes entire component subtrees to re-render.

**What to look for:**
- A single `Context.Provider` wrapping the entire app with state that changes frequently
- Components deeply nested under a provider that re-render on unrelated state changes

**Severity:** NOTICE — but can become WARNING in large trees with many expensive child components.

---

### OVER-ENGINEERING CHECKS

Over-engineering introduces **accidental complexity** — abstractions, patterns, and infrastructure that cost more to maintain than the value they deliver. This section detects patterns where the architectural overhead outweighs the actual problem being solved.

> Rule: Flag over-engineering only when evidence of unnecessary complexity is observable, not when code "could be simpler."

#### X1 — Abstraction Layers With No Behavior (Empty Pass-Through)
**Pattern:** Classes, interfaces, or services that add a layer of indirection without adding logic, validation, or transformation — pure delegation chains.

**What to look for:**
```typescript
// PROBLEM — service does nothing but call the repository
class UserService {
  constructor(private readonly userRepo: UserRepository) {}

  async getUser(id: string) {
    return this.userRepo.findById(id); // zero added value
  }

  async createUser(data: CreateUserDto) {
    return this.userRepo.save(data); // no validation, no domain logic, no mapping
  }
}

// PROBLEM — repository re-wraps the ORM with no value
class UserRepository {
  async findById(id: string) {
    return this.prisma.user.findUnique({ where: { id } }); // one-liner that could be inline
  }
}
```

**Severity:** NOTICE — but becomes WARNING when there are 3+ pass-through layers (controller → service → repository → ORM) with zero logic at any intermediate layer.

**Fix reference:** `references/over-engineering.md#empty-abstractions`

---

#### X2 — Premature Generalization (Over-Parametrized Functions)
**Pattern:** Functions with many optional parameters, strategy objects, or plugin hooks designed for flexibility that is never actually used.

**What to look for:**
```typescript
// PROBLEM — 7 options for a function called with defaults 100% of the time
interface FetchOptions {
  retries?: number;
  timeout?: number;
  cache?: boolean;
  cacheKey?: string;
  cacheTtl?: number;
  transform?: (data: unknown) => unknown;
  validate?: (data: unknown) => boolean;
}

async function fetchData(url: string, options: FetchOptions = {}) { ... }

// Called everywhere as:
const data = await fetchData('/api/users'); // never uses any options
```

**Severity:** NOTICE — flag when: the function has 5+ optional parameters AND the non-default usage is 0 or 1 call site.

**Fix reference:** `references/over-engineering.md#premature-generalization`

---

#### X3 — Infrastructure Introduced Before the Problem Exists
**Pattern:** Heavy infrastructure (message queues, event buses, microservices split, CQRS) introduced without evidence of the scaling problem it solves.

**What to look for:**
- A RabbitMQ/Kafka/SQS queue that publishes to a single consumer that could be a direct function call
- CQRS (separate read/write models) on a single-database app with no read/write ratio problem
- An event bus (`EventEmitter` subclass with 20 event types) for a single-server app
- Microservices with shared databases (negates the main benefit of microservices)

```typescript
// PROBLEM — event bus for what is literally a sequential flow
eventBus.emit('user.created', user);
// ... in another file ...
eventBus.on('user.created', async (user) => {
  await sendWelcomeEmail(user); // could just be called directly after createUser()
});
```

**Severity:** WARNING — over-infrastructure adds operational cost (deployment complexity, debugging, latency) with no benefit at current scale.

**Fix reference:** `references/over-engineering.md#premature-infrastructure`

---

#### X4 — Design Patterns Applied Without Justification
**Pattern:** Classic Gang-of-Four or enterprise patterns (Factory, Strategy, Observer, Decorator, Unit of Work) applied to scenarios too simple to need them.

**What to look for:**
```typescript
// PROBLEM — Factory for a class with a single implementation
interface IUserFactory {
  create(data: CreateUserDto): User;
}
class UserFactory implements IUserFactory {
  create(data: CreateUserDto): User {
    return new User(data.id, data.email, data.name); // just use `new User()` directly
  }
}

// PROBLEM — Strategy pattern for a switch with 2 cases that won't grow
interface SortStrategy { sort(items: Item[]): Item[]; }
class AscendingSort implements SortStrategy { ... }
class DescendingSort implements SortStrategy { ... }
// Used as: new Sorter(new AscendingSort()).sort(items)
// Should be: items.sort((a, b) => a.name.localeCompare(b.name))

// PROBLEM — Unit of Work wrapping a single ORM that already handles transactions
class UnitOfWork {
  constructor(private userRepo: UserRepo, private orderRepo: OrderRepo) {}
  async commit() { /* wraps Prisma.$transaction */ }
}
```

**Severity:** NOTICE — flag when the pattern adds more lines than the problem it solves. Patterns are justified when there are 3+ implementations or clear extension points in use.

**Fix reference:** `references/over-engineering.md#unnecessary-patterns`

---

## Step 3 — Audit Report

After running all applicable checks, produce this exact output format:

```text
╔══════════════════════════════════════╗
║      PERFORMANCE AUDIT REPORT        ║
╚══════════════════════════════════════╝

STACK DETECTED:
  Backend:  <detected or "not found">
  Frontend: <detected or "not found">
  Database: <detected or "not found">

────────────────────────────────────────
🔴 CRITICAL  (<count> found)
────────────────────────────────────────
[B1] N+1 Query
  File: src/services/user.service.ts:42
  Detail: Loop over userIds fires one findUnique per iteration.
  Impact: 100 users = 101 DB queries. 10k users = 10,001 DB queries.

[D1] Missing Index
  File: prisma/schema.prisma:12 (User.email)
  Detail: email is used in WHERE clauses but has no @unique or @@index.
  Impact: Full table scan on every login attempt.

────────────────────────────────────────
🟡 WARNING   (<count> found)
────────────────────────────────────────
[B3] Unpaginated Endpoint
  File: src/controllers/product.controller.ts:28
  Detail: findMany() called with no take or skip.
  Impact: Returns all rows. Will OOM on large tables.

[F2] Missing Lazy Loading
  File: src/pages/dashboard.tsx:3
  Detail: ReactQuill imported synchronously.
  Impact: ~200KB added to initial bundle for all users.

────────────────────────────────────────
🔵 NOTICE    (<count> found)
────────────────────────────────────────
[F5] Context Re-render Risk
  File: src/context/AppContext.tsx
  Detail: Scroll position stored in root Context.
  Impact: Every scroll event re-renders the full app tree.

════════════════════════════════════════
⭐ TOP 3 QUICK WINS
════════════════════════════════════════
[see Quick Wins section below]
```

---

## Quick Wins Output Format

After the summary table, produce a "Quick Wins" section with a before/after fix for the top 3 findings ranked by severity:

```text
QUICK WIN #1 — [Check ID] [Check Name]
File: <path:line>

BEFORE:
  <problematic code snippet>

AFTER:
  <fixed code snippet>

WHY: <one sentence explaining the performance impact>
```

---

## References

Detailed knowledge base for each bottleneck category:

- [`references/backend-bottlenecks.md`](references/backend-bottlenecks.md) — N+1, blocking I/O, pagination, caching patterns
- [`references/connection-bottlenecks.md`](references/connection-bottlenecks.md) — pool exhaustion, connection leaks, timeouts, long transactions
- [`references/database-bottlenecks.md`](references/database-bottlenecks.md) — indexing strategies, query optimization, transactions
- [`references/complexity-bigO.md`](references/complexity-bigO.md) — O(n²) patterns, linear-to-constant transforms, recursion memoization, sorting
- [`references/frontend-bottlenecks.md`](references/frontend-bottlenecks.md) — memoization, lazy loading, bundle optimization, image best practices
- [`references/over-engineering.md`](references/over-engineering.md) — empty abstractions, premature generalization, unnecessary infrastructure, pattern misuse
