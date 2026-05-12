# Pattern: Cursor Pagination

**Commandment:** #4 — Thou shalt paginate with cursor, not `skip`

## Problem
`skip: 10000` forces Mongo to walk and discard 10,000 documents: **O(n + skip)**. On a 10M-row collection, this is a production outage.

## Correct Implementation
```ts
const PAGE_SIZE = 20

async function getPostsPage(lastId?: string) {
  const page = await prisma.post.findMany({
    take: PAGE_SIZE,
    ...(lastId && {
      cursor: { id: lastId },
      skip: 1, // skip the cursor itself
    }),
    orderBy: { id: 'asc' },
    select: { id: true, title: true, publishedAt: true },
  })

  return {
    data: page,
    nextCursor: page.length === PAGE_SIZE
      ? page[page.length - 1].id
      : null,
  }
}
```

## Why it works
- Cursor jumps directly to the indexed `id` value: **O(log n)**.
- Mongo scans exactly `PAGE_SIZE` documents, no discard phase.
- Consistent results even if new rows are inserted between pages (no offset drift).

## Requirements
- The cursor field must be **unique** and **indexed** (e.g., `@id`).
- `orderBy` must match the index sort direction.

## When `skip` is acceptable
- Admin tools with <10k rows.
- Jumpable page numbers where you have **measured** the latency and it's <50ms.
- Everything else: cursor.

## Anti-pattern: Deep offset
```ts
// ❌ O(n + skip) — kills your cluster on page 5000
await prisma.post.findMany({ skip: 100000, take: 20 })
```
