# Troubleshooting: COLLSCAN Alerts

## Symptom
Atlas Performance Advisor flags `COLLSCAN` on a query.
Query latency spikes from 5ms to 500ms+.
`executionStats` shows `totalDocsExamined` >> `nReturned`.

## One-Command Diagnosis
```js
// Run in mongosh against the slow query
db.orders.find({ userId: "..." }).sort({ createdAt: -1 }).explain("executionStats")

// Bad output:
// winningPlan.stage: "COLLSCAN"
// totalDocsExamined: 10,000,000
// nReturned: 20
```

## Fix NOW
1. **Build the missing index** (background on replica sets):
```js
db.orders.createIndex(
  { userId: 1, createdAt: -1 },
  { background: true }
)
```

2. **Verify the fix:**
```js
db.orders.find({ userId: "..." }).sort({ createdAt: -1 }).explain("executionStats")
// Good output:
// winningPlan.stage: "IXSCAN"
// totalDocsExamined ≈ nReturned
```

## Root Cause Checklist
- [ ] Field in `where` has no index?
- [ ] Compound index exists but ESR is violated? (sort field before equality)
- [ ] Query shape changed after index was built? (new `$or` clause, new sort)
- [ ] Index exists but query uses `$nin` or `$regex` without anchored prefix?

## Prevention
- **Commandment #2** — declare indexes before the first `findMany`.
- **Commandment #13** — design compound indexes from actual query patterns.
- **Commandment #11** — leading field must be selective.
- Every new query shape must be verified with `explain("executionStats")` in staging.

## When it's NOT an index problem
- `$ne`, `$nin`, `$exists: false` — these often can't use indexes efficiently.
- `$regex: /foo/` (no anchor) — always COLLSCAN. Use text index or anchored regex (`/^foo/`).
- Query returns >50% of collection — index may not help; consider pre-aggregation or architectural change.

## Related Commandments
**#2, #11, #13** — ESR ordering, selectivity, compound over intersection.
