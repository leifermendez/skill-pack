# Anti-pattern: Aggregating in JavaScript Instead of MongoDB

**Commandment:** #7 — Thou shalt aggregate in the database, not in Node

## The Code
```ts
// ❌ Loads 100k documents into Node heap, then reduces in single-threaded JS
const orders = await prisma.order.findMany({
  where: { createdAt: { gte: lastMonth } },
})

const totals = orders.reduce((acc, o) => {
  acc[o.status] = (acc[o.status] || 0) + o.total
  return acc
}, {})
```

## The Cost
- `findMany` pulls **all** matching documents into Node memory.
- 100k documents × ~500 bytes each = **50MB** of heap.
- `.reduce()` runs on a single thread. No indexes help.
- Node event loop blocks. Other requests starve.
- Memory pressure triggers GC thrashing. Latency spikes for unrelated endpoints.

## The Fix
```ts
// ✅ Mongo's aggregation engine runs in parallel on disk with indexes
const totals = await prisma.order.groupBy({
  by: ['status'],
  where: { createdAt: { gte: lastMonth } },
  _sum: { total: true },
  _count: true,
})
```

## Why it works
- Mongo's aggregation engine uses indexes, runs in C++, and can parallelize stages.
- Node receives a **tiny** result set (one row per status).
- Heap usage stays flat. Event loop is free.

## Other native aggregations
```ts
await prisma.order.count({ where: { status: 'paid' } })
await prisma.order.aggregate({ _avg: { total: true } })
await prisma.order.aggregate({ _max: { createdAt: true } })
```

## Mandamiento violado
**#7** — The #1 antipattern in code review: loading 100k documents into Node memory to run `.reduce()`. Mongo's aggregation engine runs on disk, in parallel, with indexes. Your Node process runs single-threaded on the heap.
