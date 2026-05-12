# Troubleshooting: Pool Exhausted

## Symptom
`MongoServerError: connection pool exhausted`
Atlas metrics: connections flat at `maxPoolSize` limit.
Node logs: requests piling up, timeouts increasing.

## One-Command Diagnosis
```js
// In mongosh or Atlas Data Explorer
db.serverStatus().connections
// {
//   current: 640,
//   available: 0,
//   totalCreated: 128000
// }
```
`available: 0` = pool exhausted.

## Fix NOW
1. **Restart the service** — kills leaked `PrismaClient` instances and resets connections.
2. **Deploy the singleton fix** (Commandment #1) before traffic returns.

## Root Cause Checklist
- [ ] Multiple `new PrismaClient()` calls? (missing singleton)
- [ ] Hot-reload in dev creating new clients?
- [ ] Serverless function without Prisma Accelerate?
- [ ] `maxPoolSize` too high for Atlas plan? (M10 = 640 max)

## Prevention
```ts
// lib/prisma.ts — singleton pattern (mandatory)
// See references/patterns/singleton-prisma-client.md
```

**Serverless:** use Prisma Accelerate. Direct `mongodb+srv://` from Lambda/Edge will always exhaust the pool under load.

## Related Commandment
**#1** — Thou shalt use a single PrismaClient (singleton), or pay with thy pool.
