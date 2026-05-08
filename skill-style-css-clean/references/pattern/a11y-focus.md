# Pattern: Accessible Focus

> Patrones de foco accesible: focus-visible, focus-within, skip links y outline management.

## 1. focus-visible (OBLIGATORIO)

> `focus-visible` solo muestra el outline cuando el foco viene del teclado. No aparece al hacer click.

```css
/* === Base: remove default outline === */
.btn,
.link,
.input,
.select,
.checkbox {
  outline: none;
}

/* === focus-visible reemplaza === */
.btn:focus-visible,
.link:focus-visible {
  box-shadow: 0 0 0 3px var(--color-focus);
  outline: none;
}

.input:focus-visible,
.select:focus-visible {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px var(--color-focus);
}

/* === focus-within para parent containers === */
.card--clickable:focus-within {
  box-shadow: var(--shadow-lg);
}

.card--clickable:focus-within .card__title {
  color: var(--color-primary);
}
```

## 2. Outline Styles por Token

```css
:root {
  /* Outline colors */
  --color-focus: #bfdbfe;
  --color-focus-danger: #fecaca;
  --color-focus-success: #bbf7d0;

  /* Outline widths */
  --focus-width: 3px;
  --focus-offset: 2px;

  /* Outline styles */
  --focus-ring: 0 0 0 var(--focus-width) var(--color-focus);
  --focus-ring-offset: 0 0 0 calc(var(--focus-width) + var(--focus-offset)) var(--color-surface),
                       0 0 0 calc(var(--focus-width) * 2 + var(--focus-offset)) var(--color-focus);
}
```

```css
/* Uso */
.btn:focus-visible {
  box-shadow: var(--focus-ring);
  outline: none;
}

/* Con offset (doble ring, como Tailwind) */
.btn--primary:focus-visible {
  box-shadow: var(--focus-ring-offset);
}
```

## 3. Skip Link Pattern

```css
.skip-link {
  background: var(--color-primary);
  color: var(--color-on-primary);
  font-weight: 500;
  left: var(--space-4);
  padding: var(--space-2) var(--space-4);
  position: absolute;
  top: calc(var(--space-4) * -1);
  transition: top 0.2s ease;
  z-index: var(--z-skip-link);
}

.skip-link:focus-visible {
  outline: none;
  top: var(--space-4);
}
```

```html
<a class="skip-link" href="#main-content">Saltar al contenido principal</a>
...
<main id="main-content" tabindex="-1">
```

## 4. Focus Trap (solo con JS)

> CSS no puede hacer focus trap. Es responsabilidad de JavaScript.

```js
// Helper: Focus trap para modales, drawers, etc.
function createFocusTrap(container) {
  const focusable = container.querySelectorAll(
    'a[href], button, input, select, textarea, [tabindex]:not([tabindex="-1"])'
  );
  const first = focusable[0];
  const last = focusable[focusable.length - 1];

  container.addEventListener('keydown', (e) => {
    if (e.key !== 'Tab') return;

    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  });
}
```

## 5. Focus Restauración

> Después de cerrar un modal/drawer, devolver el foco al elemento que lo abrió.

```js
// En JS del modal
const trigger = document.activeElement;
modal.show();
// ... usuario interactúa ...
modal.hide();
trigger.focus();
```

## 6. focus-within para Dropdowns

```css
/* CSS-only dropdown accesible */
.navbar__item--has-dropdown:focus-within .navbar__dropdown,
.navbar__item--has-dropdown:hover .navbar__dropdown {
  display: block;
}

/* Pero el JS debe manejar aria-expanded */
```

## 7. Tabindex Management

```html
<!-- -1: programático, no tabulable -->
<div id="main-content" tabindex="-1">

<!-- 0: tabulable en orden DOM -->
<button tabindex="0">Normal</button>

<!-- ❌ NUNCA uses tabindex > 0 -->
<button tabindex="1">Mal</button>
```

## 8. Focus Indicator Contrast

> El outline debe tener contraste 3:1 contra el fondo adyacente (WCAG 2.2).

```css
/* ❌ PROHIBIDO: outline sutil que no se ve */
.btn:focus-visible {
  box-shadow: 0 0 0 1px #ddd;
}

/* ✅ CORRECTO: outline visible y con contraste */
.btn:focus-visible {
  box-shadow: 0 0 0 3px var(--color-focus);
}

/* En dark theme */
[data-theme="dark"] .btn:focus-visible {
  box-shadow: 0 0 0 3px var(--color-focus-dark);
}
```

## Checklist

- [ ] Todos los elementos interactivos tienen `focus-visible`
- [ ] Nunca uses `outline: none` sin reemplazo con `box-shadow` o `outline` visible
- [ ] Skip link al inicio del documento
- [ ] Focus trap en modales/drawers (JS)
- [ ] Focus restoration al cerrar overlays
- [ ] No uses `tabindex > 0`
- [ ] `focus-within` para parent containers interactivos
- [ ] Outline con contraste suficiente (3:1)
- [ ] Test con solo teclado (Tab, Shift+Tab, Enter, Space, Escape)
