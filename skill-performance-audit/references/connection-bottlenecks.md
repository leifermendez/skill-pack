# Database Connection Bottlenecks

Reference guide for detecting and fixing connection pool and transaction management issues.

---

## Connection Pool Exhaustion {#pool-exhaustion}

### What It Is
Every database driver maintains a **connection pool** — a fixed set of reusable connections. When all connections are in use, new requests must wait. If the pool is too small for the concurrent load, requests queue up and eventually time out.

### The Math

```
Pool size = 5 connections
Concurrent requests = 100
Average query time = 50ms

→ At any moment, 95 requests are waiting
→ Average wait time = (95 / 5) × 50ms = 950ms added to every request
→ Under sustained load, requests time out before ever connecting
```

### Recommended Pool Sizes by Load Profile

| Traffic Profile | Recommended Pool Size | Notes |
|---|---|---|
| Development / Internal tool | 5–10 | Default ORM values are fine |
| Low traffic (<100 RPM) | 10–20 | Monitor `pool_wait_time` |
| Medium traffic (100–1k RPM) | 20–50 | Size based on avg query duration |
| High traffic (>1k RPM) | 50–100+ | Add read replicas, not just pool size |

### Fixes

**Prisma — configure via connection string:**
```
DATABASE_URL="postgresql://user:pass@host:5432/db?connection_limit=20&pool_timeout=10"
```
- `connection_limit` — max connections in pool
- `pool_timeout` — seconds to wait for a connection before throwing (fail fast)

**node-postgres (pg) — configure Pool:**
```typescript
import { Pool } from 'pg';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,                    // maximum pool size
  idleTimeoutMillis: 30_000,  // close idle connections after 30s
  connectionTimeoutMillis: 5_000, // fail fast if no connection in 5s
});

// CRITICAL: share ONE pool instance across the entire app
export default pool;
```

**TypeORM — connection pool options:**
```typescript
createDataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  extra: {
    max: 20,
    idleTimeoutMillis: 30_000,
    connectionTimeoutMillis: 5_000,
  }
});
```

**Monitoring pool health:**
```typescript
// Log pool stats to detect exhaustion before it becomes an incident
setInterval(() => {
  console.log({
    total: pool.totalCount,
    idle: pool.idleCount,
    waiting: pool.waitingCount, // this number should be near 0
  });
}, 10_000);
```

---

## Connection Leaks {#connection-leaks}

### What It Is
A connection is "leaked" when it is taken from the pool but never returned — because of an unhandled error, early return, or missing `finally` block. Each leak permanently reduces pool capacity until the server is restarted.

### Detection Pattern: Pool Slowly Shrinks Under Load
- Pool starts at 20 connections
- After 2 hours of traffic, effective capacity is 6 connections
- Server restart restores it temporarily

### Fixes

**node-postgres — always use `try/finally`:**
```typescript
// BEFORE — client leaked on error
const client = await pool.connect();
const result = await client.query('SELECT * FROM users WHERE id = $1', [id]); // throws → leaked
client.release();

// AFTER — client always released
const client = await pool.connect();
try {
  const result = await client.query('SELECT * FROM users WHERE id = $1', [id]);
  return result.rows[0];
} finally {
  client.release(); // runs even if query throws
}
```

**TypeORM — always release QueryRunner:**
```typescript
const qr = dataSource.createQueryRunner();
await qr.connect();
await qr.startTransaction();

try {
  await qr.manager.save(User, userData);
  await qr.manager.save(Profile, profileData);
  await qr.commitTransaction();
} catch (error) {
  await qr.rollbackTransaction();
  throw error;
} finally {
  await qr.release(); // ALWAYS release
}
```

**Prisma — use `$transaction` (automatic connection management):**
```typescript
// Prisma $transaction manages the connection for you — no manual release needed
await db.$transaction(async (tx) => {
  await tx.user.create({ data: userData });
  await tx.profile.create({ data: profileData });
});
```

---

## Connection Timeouts {#timeouts}

### What It Is
Without timeout configuration, a request that cannot acquire a database connection will hang indefinitely — blocking the HTTP connection and the worker thread (in thread-based servers). This turns a database slowdown into a full server hang.

### Fail-Fast Philosophy
It is always better to return a fast `503 Service Unavailable` than to let a request hang for 60 seconds. Users and upstream services can retry fast failures; indefinite hangs cause thread/connection exhaustion cascades.

### Fixes

**Set timeouts at every layer:**

```typescript
// Layer 1: Database connection acquisition timeout
const pool = new Pool({
  connectionTimeoutMillis: 5_000, // fail if no pool slot in 5s
  statement_timeout: 10_000,      // kill queries running over 10s (PostgreSQL)
  idle_in_transaction_session_timeout: 30_000, // kill idle transactions after 30s
});

// Layer 2: HTTP request timeout (Express)
import timeout from 'connect-timeout';
app.use(timeout('15s')); // return 503 if handler takes over 15s
app.use((req, res, next) => {
  if (!req.timedout) next();
});

// Layer 3: ORM query timeout (Prisma)
await db.$queryRaw`SET statement_timeout = '10s'`;
// or per-query via $executeRaw in a transaction
```

**PostgreSQL server-side statement timeout:**
```sql
-- In postgresql.conf or per connection:
SET statement_timeout = '10s';        -- cancel queries over 10s
SET lock_timeout = '5s';              -- cancel if waiting for a lock over 5s
SET idle_in_transaction_session_timeout = '30s'; -- kill idle transactions
```

---

## Long Transactions Blocking Other Queries {#long-transactions}

### What It Is
A transaction holds **row-level** or **table-level locks** for its entire duration. Long transactions block any other query that needs to write (or sometimes read) the locked rows — causing a queue of waiting queries.

### Common Causes
1. External HTTP/API calls inside a transaction (network latency = lock duration)
2. User interaction inside a transaction (rare but catastrophic)
3. Large batch operations inside a single transaction
4. Forgetting to commit (idle transaction holds locks)

### Transaction Duration Guidelines

| Duration | Verdict | Notes |
|---|---|---|
| < 100ms | Acceptable | Standard CRUD operations |
| 100ms – 1s | Watch | May be acceptable; add monitoring |
| 1s – 10s | Problem | Review for external calls or large loops |
| > 10s | Critical | Killing the transaction is safer |

### Fixes

**Move external calls OUTSIDE the transaction:**
```typescript
// BEFORE — HTTP call inside transaction holds DB lock during network RTT
await db.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id } });
  const validated = await fetch('https://id-validator.com/check'); // network lock!
  await tx.user.update({ where: { id }, data: { verified: true } });
});

// AFTER — validate first, then open the shortest possible transaction
const validated = await fetch('https://id-validator.com/check'); // outside transaction
if (!validated.ok) throw new Error('Validation failed');

await db.$transaction(async (tx) => { // transaction opens here
  await tx.user.update({ where: { id }, data: { verified: true } });
}); // transaction closes here — total lock time: ~5ms
```

**Break large batch operations into chunks:**
```typescript
// BEFORE — one transaction for 10k inserts; locks table for seconds
await db.$transaction(async (tx) => {
  for (const item of tenThousandItems) {
    await tx.item.create({ data: item });
  }
});

// AFTER — chunk into smaller transactions
const CHUNK_SIZE = 500;
for (let i = 0; i < tenThousandItems.length; i += CHUNK_SIZE) {
  const chunk = tenThousandItems.slice(i, i + CHUNK_SIZE);
  await db.$transaction(
    chunk.map(item => db.item.create({ data: item }))
  );
}

// EVEN BETTER — use createMany for bulk inserts
await db.item.createMany({ data: tenThousandItems, skipDuplicates: true });
```

**Monitor long-running transactions (PostgreSQL):**
```sql
-- Find transactions running over 30 seconds
SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '30 seconds'
  AND state != 'idle';

-- Kill a specific long-running query
SELECT pg_cancel_backend(<pid>);
-- Force-kill if cancel doesn't work:
SELECT pg_terminate_backend(<pid>);
```
