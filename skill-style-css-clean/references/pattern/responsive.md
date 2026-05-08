# Pattern: Responsive / Mobile-First

> Enfoque mobile-first con breakpoints consistentes y media queries organizadas.

## Filosofía

> **Mobile-first**: Escribes el CSS base para mobile. Cada breakpoint añade complejidad para pantallas más grandes.

```css
/* ✅ CORRECTO: Mobile-first */
.card {
  /* Mobile: 1 columna */
  display: grid;
  gap: var(--space-4);
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .card {
    /* Tablet: 2 columnas */
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .card {
    /* Desktop: 3 columnas */
    grid-template-columns: repeat(3, 1fr);
  }
}
```

```css
/* ❌ PROHIBIDO: Desktop-first (override-heavy) */
.card {
  grid-template-columns: repeat(3, 1fr);  /* Desktop */
}

@media (max-width: 1024px) {
  .card {
    grid-template-columns: repeat(2, 1fr);  /* Override tablet */
  }
}

@media (max-width: 768px) {
  .card {
    grid-template-columns: 1fr;  /* Override mobile */
  }
}
```

## Breakpoints Tokenizados

```css
/* No usables en @media directamente, pero como referencia */
:root {
  --bp-sm: 640px;
  --bp-md: 768px;
  --bp-lg: 1024px;
  --bp-xl: 1280px;
  --bp-2xl: 1536px;
}
```

```css
/* SCSS: con variables */
$bp-sm: 640px;
$bp-md: 768px;
$bp-lg: 1024px;
$bp-xl: 1280px;
$bp-2xl: 1536px;
```

## Media Queries por Componente

```css
/* ✅ CORRECTO: Media queries junto al componente */
.card {
  padding: var(--space-4);
}

@media (min-width: 768px) {
  .card {
    padding: var(--space-6);
  }
}

/* ❌ PROHIBIDO: Todas las media queries al final del archivo */
/* Esto dificulta encontrar el estilo de un componente */
```

## Container Queries (cuando sea posible)

```css
/* ✅ PREFERIDO: Component-based responsive */
.card-grid {
  container-type: inline-size;
  container-name: card-grid;
}

@container card-grid (min-width: 400px) {
  .card {
    grid-template-columns: repeat(2, 1fr);
  }
}

@container card-grid (min-width: 700px) {
  .card {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

> Container queries son preferidas sobre media queries cuando un componente puede aparecer en layouts de diferente ancho.

## Patrón: Sidebar Layout

```css
.layout {
  display: grid;
  gap: var(--space-4);
  grid-template-areas:
    'header'
    'main'
    'sidebar'
    'footer';
  grid-template-columns: 1fr;
}

.layout__header  { grid-area: header; }
.layout__main    { grid-area: main; }
.layout__sidebar { grid-area: sidebar; }
.layout__footer  { grid-area: footer; }

@media (min-width: 1024px) {
  .layout {
    grid-template-areas:
      'header header'
      'sidebar main'
      'footer footer';
    grid-template-columns: 16rem 1fr;
  }
}
```

## Patrón: Typography Responsive

```css
/* Fluid typography con clamp() */
:root {
  --font-size-base: clamp(1rem, 0.95rem + 0.25vw, 1.125rem);
  --font-size-lg: clamp(1.125rem, 1rem + 0.5vw, 1.25rem);
  --font-size-xl: clamp(1.25rem, 1.1rem + 0.75vw, 1.5rem);
  --font-size-2xl: clamp(1.5rem, 1.2rem + 1.5vw, 2.25rem);
}
```

## Orden de Media Queries en BEM

```css
.btn {
  /* Base mobile */
  padding: var(--space-2) var(--space-4);
  font-size: var(--font-size-base);
}

/* === Modifiers (sin media query) === */
.btn--lg {
  padding: var(--space-3) var(--space-6);
  font-size: var(--font-size-lg);
}

/* === Estados (sin media query) === */
.btn:hover { }
.btn:focus-visible { }

/* === Media queries al final del bloque === */
@media (min-width: 768px) {
  .btn {
    padding: var(--space-3) var(--space-5);
  }
}
```

## Reglas

- [ ] **Mobile-first**: `min-width`, nunca `max-width` solo.
- [ ] **Breakpoints consistentes**: 640, 768, 1024, 1280, 1536.
- [ ] **Media queries por componente**: No agrupes todas las MQ al final del archivo.
- [ ] **Preferir `clamp()`** para tipografía fluida.
- [ ] **Preferir Container Queries** cuando el componente es reutilizable en diferentes layouts.
- [ ] **Un solo eje de cambio**: O cambias layout, o cambias tamaño, o cambias visibilidad. No todo a la vez.
