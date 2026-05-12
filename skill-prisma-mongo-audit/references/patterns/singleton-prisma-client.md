# Pattern: Singleton PrismaClient

**Commandment:** #1 — Thou shalt use a single PrismaClient (singleton), or pay with thy pool

## Problem
Every `new PrismaClient()` opens a new connection pool. In serverless, this exhausts Atlas within minutes.

## Correct Implementation
```ts
// lib/prisma.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient }

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development'
      ? ['query', 'warn', 'error']
      : ['error'],
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

## Why it works
- `globalThis` survives hot-reloads in dev and keeps one instance per Node process.
- In production, the module system caches the export, so `import` returns the same client.
- One pool = one set of connections = Atlas stays healthy.

## Connection String Template (Production)
```
mongodb+srv://USER:PASS@cluster.mongodb.net/db?retryWrites=true&w=majority&maxPoolSize=10&minPoolSize=2&serverSelectionTimeoutMS=5000&socketTimeoutMS=30000
```

## Serverless Variant (Prisma Accelerate)
```ts
import { PrismaClient } from '@prisma/client/edge'
import { withAccelerate } from '@prisma/extension-accelerate'

export const prisma = new PrismaClient().$extends(withAccelerate())
```
- Connection string: `prisma://accelerate.prisma-data.net/?api_key=...`
- Do NOT add `maxPoolSize`/`minPoolSize` to the Accelerate URL.

## Verification
```ts
// In a health-check endpoint
const metrics = await prisma.$metrics.json()
// Inspect connection pool size vs Atlas limits
```
