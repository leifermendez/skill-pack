# SaaS Schema Example — Production-Ready Prisma + MongoDB

Complete `schema.prisma` for a multi-tenant SaaS with users, posts, comments, orders, and sessions. Every index type from the 15 commandments is represented.

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mongodb"
  url      = env("DATABASE_URL")
}

model User {
  id            String    @id @default(auto()) @map("_id") @db.ObjectId
  email         String    @unique
  name          String
  role          String    @default("user")
  isActive      Boolean   @default(true)
  referralCode  String?
  location      Json?     // { type: "Point", coordinates: [lng, lat] }
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  posts     Post[]
  comments  Comment[]
  orders    Order[]
  sessions  Session[]

  // Basic equality + compound for dashboard queries
  @@index([role, isActive, createdAt(sort: Desc)])
  @@index([email])

  // Geo index for "users near me" — created via raw MongoDB (not native in Prisma)
  // Raw: db.users.createIndex({ location: "2dsphere" })
  // See Commandment #14

  @@map("users")
}

model Post {
  id          String   @id @default(auto()) @map("_id") @db.ObjectId
  userId      String   @db.ObjectId
  title       String
  content     String
  published   Boolean  @default(false)
  publishedAt DateTime?
  createdAt   DateTime @default(now())

  author   User      @relation(fields: [userId], references: [id])
  comments Comment[]

  // ESR: Equality (userId) → Sort (createdAt Desc) → Range (published)
  @@index([userId, createdAt(sort: Desc), published])
  // Feed query: published posts sorted by publishedAt
  @@index([published, publishedAt(sort: Desc)])

  @@map("posts")
}

model Comment {
  id        String   @id @default(auto()) @map("_id") @db.ObjectId
  postId    String   @db.ObjectId
  userId    String   @db.ObjectId
  body      String
  createdAt DateTime @default(now())

  post Post @relation(fields: [postId], references: [id])
  user User @relation(fields: [userId], references: [id])

  // Foreign key indexes (mandatory for $lookup performance, Commandment #5)
  @@index([postId, createdAt(sort: Desc)])
  @@index([userId])

  @@map("comments")
}

model Order {
  id        String   @id @default(auto()) @map("_id") @db.ObjectId
  userId    String   @db.ObjectId
  status    String   @default("pending")
  total     Int
  createdAt DateTime @default(now())

  user User @relation(fields: [userId], references: [id])

  // Covered query index: userId + createdAt + status (Commandment #12)
  // Supports: find orders by user, sorted, with status in select
  @@index([userId, createdAt(sort: Desc), status])
  // Admin aggregate by status
  @@index([status, createdAt])

  @@map("orders")
}

model Session {
  id        String   @id @default(auto()) @map("_id") @db.ObjectId
  userId    String   @db.ObjectId
  token     String   @unique
  expiresAt DateTime
  createdAt DateTime @default(now())

  user User @relation(fields: [userId], references: [id])

  // Foreign key for cleanup queries
  @@index([userId])

  // TTL index — created via raw MongoDB (not native in Prisma)
  // Raw: db.sessions.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 })
  // See Commandment #14

  @@map("sessions")
}
```

---

## Raw Index Scripts (MongoDB Shell)

Every non-basic index must be documented as a migration script.

```js
// migrations/001_initial_indexes.js
// Run against staging, then production

db.users.createIndex({ location: "2dsphere" })
db.sessions.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 })

// Partial index: only index active users' emails (Commandment #14)
db.users.createIndex(
  { email: 1 },
  { partialFilterExpression: { isActive: true } }
)

// Sparse + unique: referral code is unique only when present
// Note: Prisma @unique already enforces this at app level;
// use raw sparse unique only if you need DB-level enforcement with nulls allowed
db.users.createIndex(
  { referralCode: 1 },
  { sparse: true, unique: true }
)
```

---

## How to use this example

1. Copy the schema into your `schema.prisma`.
2. Run `prisma generate` to validate.
3. Create `migrations/001_initial_indexes.js` with the raw commands above.
4. Apply raw indexes via `mongosh` or Atlas UI.
5. Verify each query shape with `explain("executionStats")` before shipping.
