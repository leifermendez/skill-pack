# Pattern: Specialized Index Types

**Commandment:** #14 — Thou shalt use the right specialized index — TTL, partial, sparse, unique, text, 2dsphere

A regular B-tree index is the default tool. Mongo has five specialized variants that solve specific problems an order of magnitude better. A senior engineer reaches for them deliberately.

## TTL — Expire Documents Automatically
Sessions, OTPs, magic links, password reset tokens, cache rows.
```js
db.sessions.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 })
```
Zero application code, zero cron jobs.

## Partial — Index Only Matching Rows
Saves space, makes low-cardinality fields useful, speeds up the "active records" case.
```js
db.users.createIndex(
  { email: 1 },
  { partialFilterExpression: { isActive: true } }
)
```

## Sparse + Unique — Optional Unique Fields
Useful when a field is nullable but must be unique when present.
```js
db.users.createIndex({ referralCode: 1 }, { sparse: true, unique: true })
```

## Unique — Database-Level Enforcement
Don't rely on app-level "check then insert" — it races.
```prisma
model User {
  email String @unique // Prisma generates a unique index
}
```

## Text — Full-Text Search
Use instead of `$regex` for human-readable search. Regex without an anchored prefix (`/^foo/`) does a COLLSCAN — every time.

## 2dsphere — Geospatial Queries
Required for any "find restaurants within 5km" pattern. A B-tree on `[lat, lng]` won't help — geo needs spherical math.

## Rule of Thumb
If your data has a *kind* (expiring, optional, geographic, searchable, mostly-filtered), there's a specialized index for it. Use it.
