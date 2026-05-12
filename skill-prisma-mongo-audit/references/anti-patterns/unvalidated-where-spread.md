# Anti-pattern: Spreading Untrusted Input into `where`

**Commandment:** #8 — Thou shalt not trust user input, not even in `where`

## The Code
```ts
// ❌ NoSQL injection vector — req.body can contain Mongo operators
app.post('/api/users', async (req, res) => {
  const users = await prisma.user.findMany({ where: req.body })
  res.json(users)
})
```

## The Attack
```json
// POST /api/users
{ "role": { "$ne": "admin" } }
```
- Prisma's typed API may not catch all NoSQL operators if the shape is unexpected.
- Attacker bypasses auth checks by selecting all non-admin users.
- Worse: `{ "$where": "this.password.length > 0" }` can leak data via side channels.

## The Fix
```ts
import { z } from 'zod'

const QuerySchema = z.object({
  role: z.enum(['user', 'editor']).optional(),
  active: z.boolean().optional(),
  limit: z.number().int().min(1).max(100).default(20),
})

app.post('/api/users', async (req, res) => {
  const { role, active, limit } = QuerySchema.parse(req.body)

  const users = await prisma.user.findMany({
    where: { role, active },
    take: limit,
    select: { id: true, email: true, name: true },
  })

  res.json(users)
})
```

## Why it works
- Zod validates shape **before** Prisma sees it. Unknown keys are stripped or rejected.
- `role` is constrained to known enum values. `$ne` is impossible.
- `limit` is bounded to max 100. No `take: 999999` OOM attacks.

## Raw query variant
```ts
// ✅ Parameterized — safe
await prisma.$queryRaw`SELECT * FROM users WHERE id = ${userId}`

// ❌ String interpolation — injectable
await prisma.$queryRawUnsafe(`SELECT * FROM users WHERE id = '${userId}'`)
```

## Mandamiento violado
**#8** — Never spread untrusted input into `where`. Validate request shape with Zod / Valibot / Yup before it touches Prisma.
