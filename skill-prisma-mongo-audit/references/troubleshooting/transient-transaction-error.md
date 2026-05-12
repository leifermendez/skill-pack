# Troubleshooting: TransientTransactionError

## Symptom
`TransientTransactionError: Transaction has been aborted.`
Logs show retries failing after N attempts.
Writes inside `$transaction` intermittently fail under load.

## One-Command Diagnosis
```js
// Check MongoDB logs (Atlas → Metrics → Logs)
// Look for: TransientTransactionError with operation times > 5s
```

## Fix NOW
1. **Increase transaction timeout:**
```ts
await prisma.$transaction(
  async (tx) => {
    // atomic writes here
  },
  {
    maxWait: 5000,  // default is 2000
    timeout: 10000, // default is 5000
  }
)
```

2. **If the transaction wraps independent reads, remove it:**
```ts
// ❌ Serial, transactional for no reason
await prisma.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id } })
  const posts = await tx.post.findMany({ where: { userId: id } })
})

// ✅ Parallel, no transaction needed
const [user, posts] = await Promise.all([
  prisma.user.findUnique({ where: { id } }),
  prisma.post.findMany({ where: { userId: id }, take: 10 }),
])
```

## Root Cause
- MongoDB transactions hold snapshots and locks. Under load, conflicts trigger `TransientTransactionError`.
- Default `timeout` (5s) and `maxWait` (2s) are too aggressive for busy replica sets.
- Wrapping independent reads in a transaction wastes locks for zero benefit.

## Prevention
- **Commandment #9** — use `$transaction` only for true atomicity (debit A, credit B).
- Keep transactions small (2-3 operations max).
- Index all fields involved in transaction queries to reduce lock duration.

## Related Commandment
**#9** — Thou shalt use `$transaction` only when atomicity matters, not by reflex.
