# Pattern: Index Audit

**Commandment:** #15 — Thou shalt audit indexes — every one has a write cost, drop the unused

## The Write Tax
**Every index is taxed on every write.** Insert a document → Mongo updates every index on that collection. Update a field → every index touching that field gets rewritten. Five indexes on a hot collection means each write does six operations (one doc + five index updates).

## Symptoms of Over-Indexing
- Write latency creeping up
- Replication lag spiking under load
- Working set ballooning past RAM
- Oplog churn increasing

## Audit with `$indexStats`
```js
db.orders.aggregate([{ $indexStats: {} }])
// Look for: { name: "...", accesses: { ops: 0 } }  → unused, drop it.
```

## Three Operational Rules

1. **Hunt unused indexes monthly.** Run `$indexStats` on hot collections. Any index with `ops: 0` after a full traffic cycle (a week minimum) is a candidate for removal. Atlas Performance Advisor surfaces these automatically.

2. **Hunt redundant indexes.** An index on `[A, B, C]` makes `[A, B]` and `[A]` redundant by the prefix rule. Drop the redundant ones — they cost writes and disk for zero read benefit.

3. **Build indexes the right way in production.** On a busy collection, building an index blocks writes by default. Build with `{ background: true }` on standalone, or use a **rolling index build** on replica sets (build on each secondary in sequence, then step down the primary). For sharded clusters, follow the official rolling procedure. Never `createIndex` synchronously on a hot collection during peak hours.

## Heuristic
If a collection has more than ~6–8 indexes, you have a design problem. Consolidate compound indexes (#13), drop unused ones, push specialized cases to partial indexes (#14).
