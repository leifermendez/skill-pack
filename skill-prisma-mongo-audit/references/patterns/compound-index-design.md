# Pattern: Compound Index Design

**Commandments:** #2 (ESR), #13 (compound over intersection), #11 (selectivity)

## Problem
Two single-field indexes don't combine into one fast query. Mongo rarely uses index intersection, and when it does it's slower than a purpose-built compound index.

## The ESR Rule (Equality → Sort → Range)
Order your compound index fields exactly like this:
1. **Equality** fields first (`userId = ?`, `status = ?`)
2. **Sort** fields next (`createdAt DESC`)
3. **Range** fields last (`amount > 100`, `age < 50`)

## Correct Implementation
```prisma
model Order {
  id        String   @id @default(auto()) @map("_id") @db.ObjectId
  userId    String   @db.ObjectId
  status    String
  amount    Int
  createdAt DateTime @default(now())

  // ESR: Equality (userId, status) → Sort (createdAt) → Range (amount)
  @@index([userId, status, createdAt(sort: Desc), amount])
}
```

This single index serves:
- `where: { userId }` → prefix `[userId]` ✓
- `where: { userId, status }` → prefix `[userId, status]` ✓
- `where: { userId, status }, orderBy: { createdAt: 'desc' }` → `[userId, status, createdAt]` ✓
- `where: { userId, status, amount: { gt: 100 } }, orderBy: { createdAt: 'desc' }` → full index ✓

## Why it works
- The prefix rule: `[A, B, C]` serves queries on `[A]` and `[A, B]` automatically.
- Mongo can use the index for both filtering and sorting, avoiding in-memory sorts that blow up at 32MB.
- One compound index replaces three single-field indexes and is faster than all of them combined.

## Design from query patterns, not fields
1. List your top 5 query shapes (where + orderBy + select).
2. Build the minimum set of compound indexes covering them.
3. Respect ESR and prefix rules.
4. Verify with `explain("executionStats")`.

## Anti-pattern: Hoping for intersection
```prisma
// ❌ Two single-field indexes — Mongo will pick one and scan the rest
@@index([userId])
@@index([createdAt])
```
