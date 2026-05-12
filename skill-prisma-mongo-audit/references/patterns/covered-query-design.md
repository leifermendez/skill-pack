# Pattern: Covered Query Design

**Commandment:** #12 — Thou shalt design covered queries — index serves the projection too

## Problem
Mongo fetches the full BSON document even when you only need two fields. This wastes disk I/O, memory, and BSON→JSON CPU.

## What is a Covered Query?
A query where Mongo can answer entirely from the index, never touching the document. `executionStats` shows `totalDocsExamined: 0`.

## Correct Implementation
```prisma
model Order {
  id        String   @id @default(auto()) @map("_id") @db.ObjectId
  userId    String   @db.ObjectId
  status    String
  total     Int
  createdAt DateTime @default(now())

  @@index([userId, createdAt(sort: Desc), status])
}
```

```ts
await prisma.order.findMany({
  where: { userId, status: 'paid' },          // in index ✓
  orderBy: { createdAt: 'desc' },             // in index ✓
  select: { userId: true, createdAt: true, status: true }, // in index ✓
  take: 20,
})
```

## Why it works
- The index `[userId, createdAt, status]` contains all three fields.
- Mongo traverses the B-tree, returns the leaf node data directly.
- No FETCH stage. No document lookup.

## Verification
```js
db.orders.find({ userId: "...", status: "paid" })
  .sort({ createdAt: -1 })
  .explain("executionStats")
// winningPlan: { stage: "IXSCAN" }
// totalDocsExamined: 0  ← covered
```

## Trade-off
Wider indexes consume more disk and RAM. Cover only **hot, read-heavy queries** — the ones that run thousands of times per minute or appear in the slow query log. Don't bloat every index for marginal gain.

## Anti-pattern: Adding a field outside the index
```ts
select: { userId: true, createdAt: true, status: true, total: true }
// total is NOT in the index → Mongo must fetch the document → uncovered
```
