# Database Performance Bottlenecks

Reference guide for detecting and fixing common database and ORM performance issues.

---

## Missing Indexes {#missing-indexes}

### What It Is
A database index is a data structure (B-tree by default) that allows the database to find rows matching a condition in O(log n) time instead of O(n) (full table scan). Without indexes, every query reads every row in the table.

### Why It Is Catastrophic

| Table Size | Without Index | With Index |
|---|---|---|
| 1,000 rows | ~1ms | ~0.1ms |
| 100,000 rows | ~100ms | ~0.5ms |
| 10,000,000 rows | ~10,000ms (10s) | ~2ms |

- Full table scans grow linearly. Indexes scale logarithmically.
- Every login attempt scanning `users` by email without an index is a full table scan.
- Unindexed foreign keys make JOINs exponentially slow.

### Detection Patterns

**Prisma schema — missing `@unique` or `@@index`:**
```prisma
model User {
  id        String   @id @default(cuid())
  email     String   // PROBLEM — queried with WHERE email = ? on every auth
  createdAt DateTime @default(now()) // PROBLEM — if used in ORDER BY on large tables
  teamId    String   // PROBLEM — foreign key without index makes JOIN slow
  team      Team     @relation(fields: [teamId], references: [id])
}

model Order {
  id        String   @id
  status    String   // PROBLEM — if queried with WHERE status = 'pending' frequently
  userId    String   // PROBLEM — foreign key without index
  user      User     @relation(fields: [userId], references: [id])
}
```

**TypeORM — missing `@Index()` or `@Unique()`:**
```typescript
@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  email: string; // PROBLEM — no @Unique() or @Index()

  @Column()
  @ManyToOne(() => Team)
  teamId: string; // PROBLEM — foreign key without @Index()
}
```

### Fixes

**Prisma — add indexes:**
```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique           // unique index — fastest for exact match
  createdAt DateTime @default(now())
  teamId    String

  team Team @relation(fields: [teamId], references: [id])

  @@index([teamId])                    // index on foreign key
  @@index([createdAt])                 // index for ORDER BY / range queries
}

model Order {
  id     String @id
  status String
  userId String

  user User @relation(fields: [userId], references: [id])

  @@index([userId])                    // index on foreign key
  @@index([status])                    // index for frequent filter
  @@index([userId, status])            // composite index for combined queries
}
```

**TypeORM — add decorators:**
```typescript
@Entity()
@Index(['status', 'userId']) // composite index
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  status: string;

  @Column()
  @ManyToOne(() => User)
  @Index()
  userId: string;
}

@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true }) // unique index
  email: string;
}
```

### When to Use Composite Indexes
Use a composite index when queries frequently filter or sort on multiple columns together:
```sql
-- This query benefits from a composite index on (userId, status)
SELECT * FROM orders WHERE userId = ? AND status = 'pending' ORDER BY createdAt DESC;
```

**Rule:** The column with the highest cardinality (most unique values) should come first.

---

## Over-Fetching (SELECT *) {#over-fetching}

### What It Is
Querying all columns from a table when only a few are needed. The database transmits, deserializes, and allocates memory for data that is immediately discarded.

### Why It Matters
- Tables often have large `TEXT`, `JSON`, `BYTEA`, or `BLOB` columns (user bios, metadata, files)
- Fetching 100 user rows with a 10KB bio each = 1MB of wasted data per query
- Increases network latency between database and application server
- Consumes more memory in the application process

### Detection Patterns

```typescript
// PRISMA — fetching all fields when only email and name are needed
const user = await db.user.findUnique({ where: { id } });
// returns: id, email, name, bio, avatarUrl, passwordHash, createdAt, updatedAt, metadata

// TYPEORM
const users = await userRepo.find(); // all columns
const user = await userRepo.findOne({ where: { id } }); // all columns

// MONGOOSE
const users = await User.find({}); // all fields
```

### Fixes

**Prisma — use `select`:**
```typescript
// BEFORE — fetches all 10 columns including passwordHash and large bio
const user = await db.user.findUnique({ where: { id } });

// AFTER — fetches only 3 columns needed for the response
const user = await db.user.findUnique({
  where: { id },
  select: { id: true, email: true, name: true }
});
```

**TypeORM — use `select` option:**
```typescript
// BEFORE
const user = await userRepo.findOne({ where: { id } });

// AFTER
const user = await userRepo.findOne({
  where: { id },
  select: { id: true, email: true, name: true }
});
```

**Mongoose — use projection:**
```typescript
// BEFORE
const user = await User.findById(id);

// AFTER — second arg is projection: 1 = include, 0 = exclude
const user = await User.findById(id, { email: 1, name: 1, _id: 1 });
// or exclude sensitive fields:
const user = await User.findById(id).select('-passwordHash -refreshToken');
```

---

## Missing Transactions for Multi-Step Writes {#transactions}

### What It Is
A database transaction groups multiple operations into an atomic unit — either all succeed or all are rolled back. Without transactions, partial failures leave the database in an inconsistent state.

### Why It Is Critical
- E-commerce: order created but inventory not deducted → overselling
- Finance: debit applied but credit not → money lost
- Auth: user created but role not assigned → broken access control

### Detection Patterns

```typescript
// PROBLEM — two writes with no transaction
async function createOrder(userId: string, items: Item[]) {
  const order = await db.order.create({ data: { userId, total: 100 } });
  // If this throws, order exists with no items
  await db.orderItem.createMany({ data: items.map(i => ({ ...i, orderId: order.id })) });
  // If this throws, inventory is not deducted but order is confirmed
  await db.inventory.updateMany({ ... });
}
```

### Fixes

**Prisma — interactive transactions:**
```typescript
async function createOrder(userId: string, items: Item[]) {
  return db.$transaction(async (tx) => {
    const order = await tx.order.create({ data: { userId, total: 100 } });

    await tx.orderItem.createMany({
      data: items.map(i => ({ ...i, orderId: order.id }))
    });

    for (const item of items) {
      await tx.inventory.update({
        where: { productId: item.productId },
        data: { stock: { decrement: item.quantity } }
      });
    }

    return order;
    // If any step above throws, ALL writes are rolled back automatically
  });
}
```

**TypeORM — QueryRunner transactions:**
```typescript
async function transferFunds(fromId: string, toId: string, amount: number) {
  const queryRunner = dataSource.createQueryRunner();
  await queryRunner.connect();
  await queryRunner.startTransaction();

  try {
    await queryRunner.manager.decrement(Account, { id: fromId }, 'balance', amount);
    await queryRunner.manager.increment(Account, { id: toId }, 'balance', amount);
    await queryRunner.commitTransaction();
  } catch (error) {
    await queryRunner.rollbackTransaction();
    throw error;
  } finally {
    await queryRunner.release();
  }
}
```

---

## Query Analysis Tips

### Use EXPLAIN ANALYZE (PostgreSQL)
Before and after adding an index, verify the query plan changed:

```sql
-- Before index
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';
-- Look for: "Seq Scan on users" = BAD (full table scan)

-- After adding index
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';
-- Look for: "Index Scan using users_email_key" = GOOD
```

### Slow Query Log
Enable slow query logging in production to find bottlenecks with real data:

**PostgreSQL (`postgresql.conf`):**
```
log_min_duration_statement = 100  # log queries slower than 100ms
```

**MySQL (`my.cnf`):**
```
slow_query_log = 1
long_query_time = 0.1  # 100ms threshold
```

### Prisma — Enable Query Logging
```typescript
const db = new PrismaClient({
  log: [
    { emit: 'event', level: 'query' }
  ]
});

db.$on('query', (e) => {
  if (e.duration > 100) { // log queries over 100ms
    console.warn(`Slow query (${e.duration}ms): ${e.query}`);
  }
});
```
