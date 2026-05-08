# Pattern: Card (BEM)

> Componente card flexible con estructura semántica y modifiers de variante.

## HTML

```html
<!-- Card básica -->
<article class="card">
  <header class="card__header">
    <img class="card__image" src="photo.jpg" alt="Descripción" />
    <span class="card__badge badge badge--new">Nuevo</span>
  </header>
  <div class="card__body">
    <h3 class="card__title">Título de la Card</h3>
    <p class="card__text">Descripción breve del contenido...</p>
  </div>
  <footer class="card__footer">
    <button class="btn btn--primary">Ver más</button>
    <span class="card__meta">Hace 2 días</span>
  </footer>
</article>

<!-- Card horizontal -->
<article class="card card--horizontal">
  <header class="card__header">
    <img class="card__image" src="photo.jpg" alt="" />
  </header>
  <div class="card__body">
    <h3 class="card__title">Card Horizontal</h3>
    <p class="card__text">Contenido...</p>
  </div>
</article>

<!-- Card featured -->
<article class="card card--featured">
  <div class="card__body">
    <h3 class="card__title">Destacado</h3>
    <p class="card__text">Este es un elemento destacado...</p>
  </div>
</article>

<!-- Card compacta -->
<article class="card card--compact">
  <div class="card__body">
    <h3 class="card__title">Compacta</h3>
  </div>
</article>
```

## CSS

```css
/* === Block === */
.card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* === Elements === */
.card__header {
  position: relative;
}

.card__image {
  aspect-ratio: 16 / 9;
  display: block;
  height: auto;
  object-fit: cover;
  width: 100%;
}

.card__badge {
  position: absolute;
  right: var(--space-3);
  top: var(--space-3);
}

.card__body {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: var(--space-2);
  padding: var(--space-4);
}

.card__title {
  font-size: var(--font-size-lg);
  font-weight: 600;
  line-height: 1.3;
  margin: 0;
}

.card__text {
  color: var(--color-text-muted);
  font-size: var(--font-size-base);
  line-height: 1.5;
  margin: 0;
}

.card__footer {
  align-items: center;
  border-top: 1px solid var(--color-border);
  display: flex;
  gap: var(--space-2);
  justify-content: space-between;
  padding: var(--space-3) var(--space-4);
}

.card__meta {
  color: var(--color-text-muted);
  font-size: var(--font-size-sm);
}

/* === Modifiers === */
.card--horizontal {
  flex-direction: row;
}

.card--horizontal .card__header {
  flex-shrink: 0;
  width: 33.333%;
}

.card--horizontal .card__image {
  aspect-ratio: 1 / 1;
  height: 100%;
}

.card--featured {
  border-left: 4px solid var(--color-primary);
}

.card--compact .card__body {
  padding: var(--space-3);
}

.card--compact .card__title {
  font-size: var(--font-size-base);
}

.card--clickable {
  cursor: pointer;
  transition: box-shadow 0.2s ease, transform 0.2s ease;
}

.card--clickable:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}

.card--clickable:focus-visible {
  box-shadow: 0 0 0 3px var(--color-focus), var(--shadow-lg);
  outline: none;
}

/* === Responsive === */
@media (max-width: 768px) {
  .card--horizontal {
    flex-direction: column;
  }

  .card--horizontal .card__header {
    width: 100%;
  }

  .card--horizontal .card__image {
    aspect-ratio: 16 / 9;
  }
}
```

## Tokens Requeridos

```css
:root {
  --color-surface: #ffffff;
  --color-border: #e2e8f0;
  --color-primary: #2563eb;
  --color-text-muted: #64748b;
  --color-focus: #93c5fd;

  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.25rem;

  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;

  --radius-lg: 12px;

  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}
```

## Checklist

- [ ] Estructura semántica: `<article>`, `<header>`, `<footer>`
- [ ] BEM puro: `.card`, `.card__header`, `.card__body`, `.card__title`, etc.
- [ ] Imagen con `aspect-ratio` y `object-fit`
- [ ] Modificadores de layout: `.card--horizontal`, `.card--compact`
- [ ] `.card--clickable` con `focus-visible` accesible
- [ ] Responsive: horizontal se apila en mobile
- [ ] Badge como block independiente (mix de BEM)
- [ ] Sin nesting CSS (solo combinador child `.card--horizontal .card__header` para modifier de layout)
