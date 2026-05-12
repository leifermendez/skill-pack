# Pattern: Index Selectivity

**Commandment:** #11 — Thou shalt respect index selectivity, not waste B-tree depth on booleans

## Problem
An index on a low-cardinality field as the **leading key** is almost useless. An index on `isActive` (2 values) means every query still scans ~50% of the collection. The B-tree filters one bit of information per node — you've paid storage cost for almost zero pruning.

## Selectivity Rule
The leading field of an index should split the dataset finely.
- **Great:** `userId` (millions of values)
- **Poor leader:** `status` with 3 values on a large collection
- **Fine as secondary:** `isPublished` after a selective `userId`

```prisma
// ❌ Useless as a standalone index — half the rows match
@@index([isPublished])

// ✅ Selective leader, low-cardinality as secondary filter
@@index([userId, isPublished, createdAt(sort: Desc)])
```

## Quick Test
```js
db.collection.distinct("field").length / db.collection.count()
```
If the ratio is below ~1% (or the field has <100 distinct values on a large collection), don't lead with it.

## Exception: Partial Indexes
Partial indexes make low-cardinality fields useful — index only the rows where `isPublished: true` and the cardinality problem disappears. See `references/patterns/specialized-indexes.md`.
