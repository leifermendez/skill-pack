# Anti-pattern: Skip/Offset Pagination on Large Collections

**Commandment:** #4 — Thou shalt paginate with cursor, not `skip`

## The Code
```ts
// ❌ O(n + skip) — grows linearly with page depth
const page = await prisma.post.findMany({
  where: { published: true },
  skip: pageNumber * pageSize,
  take: pageSize,
  orderBy: { createdAt: 'desc' },
})
```

## The Cost
| Page | `skip` | Docs examined | Latency (est.) |
|---|---|---|---|
| 1 | 0 | 20 | 2ms |
| 100 | 2,000 | 2,020 | 80ms |
| 1,000 | 20,000 | 20,020 | 800ms |
| 5,000 | 100,000 | 100,020 | 4s+ |

At page 5000, Mongo walks 100k documents and discards them. Memory and CPU spike. Atlas CPU saturates. Node process may OOM if the result set is large.

## The Fix
```ts
const page = await prisma.post.findMany({
  take: 20,
  ...(lastId && {
    cursor: { id: lastId },
    skip: 1,
  }),
  orderBy: { id: 'asc' },
})

const nextCursor = page.length === 20 ? page[page.length - 1].id : null
```

## Why it works
- Cursor jumps directly to `lastId` in the B-tree: **O(log n)**.
- Mongo scans exactly 20 documents. No discard phase.
- Latency is **flat** regardless of page depth.

## When `skip` is acceptable
- Admin tools with <10k total rows.
- Jumpable page numbers where you've **measured** latency and it's <50ms at the deepest page.

## Mandamiento violado
**#4** — `skip` over a large collection is O(n+skip). Cursor pagination over an indexed field is O(log n).
