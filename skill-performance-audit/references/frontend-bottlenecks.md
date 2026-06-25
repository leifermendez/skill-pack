# Frontend Performance Bottlenecks

Reference guide for detecting and fixing common frontend performance issues.

---

## Memoization — Expensive Computations {#memoization}

### What It Is
React re-renders a component every time its parent re-renders or its props/state change. Without memoization, expensive calculations run on every render cycle — including on unrelated state changes.

### Why It Matters
- Sorting or filtering 10k items on every keystroke causes visible frame drops
- On low-end Android devices (150MHz CPU budget per frame), a 20ms sort causes janky scrolling
- Compounds in lists: 100 items × 1ms each = 100ms of blocked rendering per frame

### Detection Patterns

```tsx
// PROBLEM — re-runs on every render, including unrelated re-renders
function ProductList({ products, searchTerm }) {
  const filtered = products
    .filter(p => p.name.includes(searchTerm))  // re-runs always
    .sort((a, b) => b.rating - a.rating);       // O(n log n) on every render

  return <ul>{filtered.map(p => <li key={p.id}>{p.name}</li>)}</ul>;
}

// PROBLEM — object/array created inline causes child re-renders
function Parent() {
  return <Child config={{ theme: 'dark' }} />; // new object reference every render
}
```

### Fixes

**`useMemo` for expensive computations:**
```tsx
import { useMemo } from 'react';

function ProductList({ products, searchTerm }) {
  const filtered = useMemo(
    () => products
      .filter(p => p.name.includes(searchTerm))
      .sort((a, b) => b.rating - a.rating),
    [products, searchTerm] // only re-runs when these change
  );

  return <ul>{filtered.map(p => <li key={p.id}>{p.name}</li>)}</ul>;
}
```

**`useCallback` for stable function references:**
```tsx
import { useCallback } from 'react';

function Parent({ onSave }) {
  const handleSave = useCallback((data) => {
    onSave(data);
  }, [onSave]); // stable reference — child won't re-render unnecessarily

  return <ExpensiveChild onSave={handleSave} />;
}
```

**`React.memo` to skip child re-renders:**
```tsx
const ExpensiveChild = React.memo(function ExpensiveChild({ onSave, config }) {
  // Only re-renders if onSave or config reference changes
  return <div>...</div>;
});
```

---

## Lazy Loading Heavy Components {#lazy-loading}

### What It Is
Importing a large component or library at the top of a file adds its entire weight to the initial JavaScript bundle — even if the user never sees that component.

### Why It Matters
- JavaScript is the most expensive resource type: it must be parsed, compiled, and executed
- 1MB of JS ≠ 1MB of image. JS blocks rendering; images don't
- Every extra KB delays Time to Interactive (TTI), which directly impacts user drop-off rates
- Lazy loading moves heavy code to a separate chunk fetched only when needed

### Detection Patterns

```tsx
// PROBLEM — these are all large bundles loaded upfront
import { Chart } from 'chart.js';             // ~200KB
import ReactQuill from 'react-quill';         // ~150KB
import { MapContainer } from 'react-leaflet'; // ~150KB
import 'react-pdf';                           // ~500KB
import Monaco from '@monaco-editor/react';    // ~2MB
```

### Fixes

**React.lazy with Suspense:**
```tsx
import { lazy, Suspense } from 'react';

// BEFORE — synchronous, always in bundle
import ReactQuill from 'react-quill';

// AFTER — loaded only when the component mounts
const ReactQuill = lazy(() => import('react-quill'));

function Editor() {
  return (
    <Suspense fallback={<div>Loading editor...</div>}>
      <ReactQuill />
    </Suspense>
  );
}
```

**Next.js dynamic import:**
```tsx
import dynamic from 'next/dynamic';

const Chart = dynamic(() => import('./Chart'), {
  loading: () => <p>Loading chart...</p>,
  ssr: false // skip server rendering for browser-only libraries
});
```

**Route-level code splitting (React Router):**
```tsx
import { lazy, Suspense } from 'react';
import { Routes, Route } from 'react-router-dom';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

---

## Image Optimization {#images}

### What It Is
Images are typically 60-80% of a page's total byte weight. Unoptimized images directly hurt Largest Contentful Paint (LCP), which is Google's primary Core Web Vital for ranking.

### Detection Patterns

```tsx
// PROBLEM 1 — raw <img> in Next.js bypasses all automatic optimization
<img src="/hero.jpg" />

// PROBLEM 2 — no lazy loading on below-the-fold images
<img src="/product.png" />

// PROBLEM 3 — no explicit dimensions causes Cumulative Layout Shift (CLS)
<img src="/avatar.jpg" />

// PROBLEM 4 — serving JPEG/PNG when WebP/AVIF would be 30-50% smaller
```

### Fixes

**Next.js — use `next/image`:**
```tsx
import Image from 'next/image';

// AFTER — automatic WebP conversion, lazy loading, size optimization
<Image
  src="/hero.jpg"
  width={1200}
  height={600}
  alt="Hero image"
  priority // only for LCP hero images above the fold
/>

// For below-the-fold images, omit priority (lazy load is the default)
<Image src="/product.jpg" width={400} height={300} alt="Product" />
```

**Vanilla HTML — add lazy loading and dimensions:**
```html
<!-- BEFORE -->
<img src="/product.jpg" />

<!-- AFTER -->
<img
  src="/product.webp"
  width="400"
  height="300"
  loading="lazy"
  alt="Product image"
/>
```

**Background images — use CSS `content-visibility`:**
```css
.below-the-fold-section {
  content-visibility: auto; /* browser skips rendering until near viewport */
  contain-intrinsic-size: 0 500px; /* hint for layout calculation */
}
```

---

## Bundle Bloat — Whole-Library Imports {#bundle-bloat}

### What It Is
Importing an entire library when only a small part of it is needed causes the full library to be included in the JavaScript bundle — even the parts never executed.

### Why It Matters
- lodash is ~70KB gzipped. `_.groupBy` alone is ~2KB
- moment.js is ~230KB gzipped (includes all locales)
- The unused code still gets parsed by the JavaScript engine

### Detection Patterns

```tsx
// PROBLEM — entire lodash library (~70KB)
import _ from 'lodash';
import * as _ from 'lodash';

// PROBLEM — all of moment.js + all locales (~230KB)
import moment from 'moment';

// PROBLEM — entire date-fns
import * as dateFns from 'date-fns';

// PROBLEM — entire Material UI icon set
import * as Icons from '@mui/icons-material';
```

### Fixes

**Lodash — import individual functions:**
```tsx
// BEFORE
import _ from 'lodash';
const grouped = _.groupBy(items, 'category');

// AFTER — only groupBy is bundled (~2KB vs ~70KB)
import groupBy from 'lodash/groupBy';
const grouped = groupBy(items, 'category');
```

**Replace moment.js with date-fns (tree-shakeable):**
```tsx
// BEFORE
import moment from 'moment'; // 230KB
const formatted = moment(date).format('YYYY-MM-DD');

// AFTER
import { format } from 'date-fns'; // ~2KB for this function only
const formatted = format(date, 'yyyy-MM-dd');
```

**Material UI icons — import individually:**
```tsx
// BEFORE — entire icon library
import { Delete, Edit, Add } from '@mui/icons-material';

// AFTER — still the same import syntax, but configure babel-plugin-import
// or use direct paths:
import Delete from '@mui/icons-material/Delete';
import Edit from '@mui/icons-material/Edit';
```

**Analyze your bundle — always verify with:**
```bash
# Next.js
ANALYZE=true next build

# Vite
npx vite-bundle-visualizer

# Create React App / Webpack
npx webpack-bundle-analyzer stats.json
```
