# Backend Performance Bottlenecks

Reference guide for detecting and fixing common backend performance issues.

---

## N+1 Queries {#n-plus-one}

### What It Is
An N+1 query problem occurs when code executes 1 query to fetch a list, then N additional queries to fetch related data for each item in the list — instead of fetching everything in a single joined query.

### Why It Is Catastrophic
- 100 users → 101 DB queries
- 10,000 users → 10,001 DB queries
- Latency scales linearly with data size
- Saturates the database connection pool under concurrent load

### Detection Patterns

```typescript
// PATTERN 1: loop with await inside
for (const order of orders) {
  const user = await db.user.findUnique({ where: { id: order.userId } }); // N+1
}

// PATTERN 2: Promise.all over individual lookups — still N+1
const users = await Promise.all(
  orders.map(o => db.user.findUnique({ where: { id: o.userId } }))
);

// PATTERN 3: Mongoose .populate() called in a loop
for (const post of posts) {
  await post.populate('author'); // N+1
}
```

### Fixes

**Prisma — use `include` for joins:**
```typescript
// BEFORE — N+1
const orders = await db.order.findMany();
for (const order of orders) {
  const user = await db.user.findUnique({ where: { id: order.userId } });
}

// AFTER — single query with join
const orders = await db.order.findMany({
  include: { user: true }
});
```

**Raw SQL / TypeORM — use `findByIds` or `IN` clause:**
```typescript
// BEFORE — N+1
const userIds = orders.map(o => o.userId);
const users = await Promise.all(userIds.map(id => userRepo.findOneBy({ id })));

// AFTER — single query
const users = await userRepo.findBy({ id: In(userIds) });
const userMap = new Map(users.map(u => [u.id, u]));
```

**DataLoader pattern for GraphQL resolvers:**
```typescript
import DataLoader from 'dataloader';

const userLoader = new DataLoader(async (userIds: string[]) => {
  const users = await db.user.findMany({ where: { id: { in: userIds } } });
  const userMap = new Map(users.map(u => [u.id, u]));
  return userIds.map(id => userMap.get(id));
});

// In resolver — batched automatically
const user = await userLoader.load(order.userId);
```

---

## Synchronous Blocking {#sync-blocking}

### What It Is
Node.js is single-threaded. Any synchronous operation (file I/O, crypto, compression) executed inside a request handler blocks the entire event loop — freezing all concurrent requests until it completes.

### Why It Is Catastrophic
- 1 synchronous 50ms file read blocks 1,000 concurrent requests for 50ms each
- Under load, a single blocking call can cascade into a full server timeout

### Detection Patterns

```typescript
// ALL of these block the event loop:
fs.readFileSync('./config.json');
fs.writeFileSync('./output.txt', data);
crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512');
zlib.gzipSync(largeBuffer);
JSON.parse(veryLargeJsonString); // technically sync but usually fine for small payloads
```

### Fixes

**Async file I/O:**
```typescript
// BEFORE
const config = fs.readFileSync('./config.json', 'utf-8');

// AFTER
const config = await fs.promises.readFile('./config.json', 'utf-8');
```

**Async crypto (bcrypt instead of pbkdf2Sync):**
```typescript
// BEFORE
const hash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');

// AFTER
import bcrypt from 'bcrypt';
const hash = await bcrypt.hash(password, 10); // non-blocking
```

**Move heavy work off the event loop with worker threads:**
```typescript
import { Worker } from 'worker_threads';

// For truly CPU-bound work (image resizing, PDF generation, etc.)
// offload to a worker thread pool
```

---

## Unpaginated Endpoints {#pagination}

### What It Is
An endpoint that returns all records in a table without any limit, cursor, or offset. Harmless at development scale, catastrophic in production.

### Why It Is Dangerous
- Returns 1M rows when the client only needs 20
- Consumes all available memory deserializing the result
- Saturates network bandwidth
- Causes OOM (out of memory) crashes on large datasets

### Detection Patterns

```typescript
// PRISMA — no take/skip
await db.product.findMany();
await db.user.findMany({ where: { active: true } }); // filtered but still unbounded

// RAW SQL
await db.query('SELECT * FROM orders');
await db.query('SELECT * FROM orders WHERE status = $1', ['pending']); // still unbounded

// MONGOOSE
await Product.find({});
await Order.find({ status: 'pending' });
```

### Fixes

**Offset pagination (simple, good for small datasets):**
```typescript
const { page = 1, limit = 20 } = req.query;
const products = await db.product.findMany({
  take: Math.min(Number(limit), 100), // cap at 100 to prevent abuse
  skip: (Number(page) - 1) * Number(limit),
  orderBy: { createdAt: 'desc' }
});
```

**Cursor pagination (better for large datasets, avoids offset drift):**
```typescript
const { cursor, limit = 20 } = req.query;
const products = await db.product.findMany({
  take: Number(limit),
  skip: cursor ? 1 : 0, // skip the cursor item itself
  cursor: cursor ? { id: cursor } : undefined,
  orderBy: { id: 'asc' }
});
const nextCursor = products[products.length - 1]?.id;
```

---

## Missing Caching {#caching}

### What It Is
Repeated expensive operations (external API calls, heavy DB aggregations, complex computations) are re-executed on every request without caching the result.

### When to Cache
Cache when ALL of these are true:
1. The data changes infrequently (or you can tolerate some staleness)
2. The operation is slow (>50ms) or expensive (network call, DB join)
3. The same data is requested more than once

### Fixes

**In-memory cache (single server, no infrastructure needed):**
```typescript
const cache = new Map<string, { data: unknown; expiresAt: number }>();

async function getCachedData(key: string, fetcher: () => Promise<unknown>, ttlMs = 60_000) {
  const cached = cache.get(key);
  if (cached && Date.now() < cached.expiresAt) return cached.data;

  const data = await fetcher();
  cache.set(key, { data, expiresAt: Date.now() + ttlMs });
  return data;
}

// Usage
const rates = await getCachedData('exchange-rates', () => fetchExchangeRates(), 5 * 60_000);
```

**Redis cache (multi-server, recommended for production):**
```typescript
import { createClient } from 'redis';
const redis = createClient({ url: process.env.REDIS_URL });

async function getOrCache<T>(key: string, fetcher: () => Promise<T>, ttlSeconds = 300): Promise<T> {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached) as T;

  const data = await fetcher();
  await redis.setEx(key, ttlSeconds, JSON.stringify(data));
  return data;
}
```

**HTTP cache headers for public read endpoints:**
```typescript
app.get('/api/categories', async (req, res) => {
  const categories = await db.category.findMany();
  res.set('Cache-Control', 'public, max-age=300'); // CDN/browser caches for 5 minutes
  res.json(categories);
});
```
