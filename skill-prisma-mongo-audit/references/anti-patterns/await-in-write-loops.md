# Anti-pattern: `await` Inside Write Loops

**Commandment:** #6 — Thou shalt batch writes or perish from round-trips

## The Code
```ts
// ❌ N round-trips, N × (RTT + writeConcern majority wait)
for (const item of items) {
  await prisma.event.create({ data: item })
}
```

## The Cost
- Each `create()` pays full network latency (RTT) + `w: majority` acknowledgment.
- 1,000 items × 20ms RTT = **20 seconds** of wall-clock time.
- The loop is **serial**: item N waits for item N-1 to finish.
- Under load, this queues connections, exhausts the pool, and triggers `TransientTransactionError`.

## The Fix
```ts
// ✅ 1 round-trip
await prisma.event.createMany({ data: events })

// ✅ Batch update
await prisma.user.updateMany({
  where: { active: false },
  data: { archived: true },
})

// ✅ Batch delete
await prisma.session.deleteMany({
  where: { expiresAt: { lt: new Date() } },
})
```

## Edge case: needing generated IDs
If you need each inserted `id` individually and can't restructure:
```ts
// Bounded concurrency — still better than serial await
import pLimit from 'p-limit'

const limit = pLimit(10)
const results = await Promise.all(
  items.map(item => limit(() => prisma.event.create({ data: item })))
)
```
- 10 concurrent creates at a time. Still N round-trips, but parallelized.
- Only valid when `createMany` is impossible due to generated ID requirements.

## Mandamiento violado
**#6** — Each iteration pays full network latency plus `w: majority` acknowledgment. 1000 items at 20ms RTT = 20 seconds. Use batch operations.
