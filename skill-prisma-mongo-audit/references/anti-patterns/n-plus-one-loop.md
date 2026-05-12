# Anti-pattern: N+1 Loop with `include` but no Index

**Commandment:** #5 — Thou shalt kill N+1 with `include`/`select`, but measure the `$lookup`

## The Code
```ts
// ❌ Prisma generates a $lookup, but the FK is unindexed → COLLSCAN on joined side
const posts = await prisma.post.findMany({
  where: { published: true },
  include: { author: true }, // $lookup on unindexed userId
  take: 20,
})
```

## The Cost
- `findMany` runs one query.
- `$lookup` runs against the `users` collection using `userId`.
- If `userId` has no index, Mongo scans the **entire** `users` collection for **each** post row.
- 20 posts × 1M users = 20M documents examined. **Production outage.**

## The Fix
```prisma
model Post {
  userId String @db.ObjectId

  @@index([userId]) // mandatory for $lookup performance
}
```

```ts
// ✅ Indexed FK + projected fields
const posts = await prisma.post.findMany({
  where: { published: true },
  select: {
    id: true,
    title: true,
    author: { select: { id: true, name: true } },
  },
  take: 20,
})
```

## Alternative: Embedded documents (Mongo's superpower)
For 1:1 or small 1:N relations always read together, use Prisma **composite types** instead of separate collections:
```prisma
type AuthorEmbed {
  id   String
  name String
}

model Post {
  id     String      @id @default(auto()) @map("_id") @db.ObjectId
  author AuthorEmbed // embedded, zero joins
}
```
- Atomic read. Zero `$lookup`. No index needed on FK.
- Only use when the embedded data is **always** read with the parent and rarely updated independently.

## Mandamiento violado
**#5** — Always index foreign keys used in `include`. Embedded vs related must be a deliberate decision, not an accident.
