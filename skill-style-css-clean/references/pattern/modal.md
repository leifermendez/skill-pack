# Pattern: Modal / Dialog (BEM)

> Modal accesible con roles ARIA, focus trap y animaciones respetando prefers-reduced-motion.

## HTML

```html
<!-- Overlay + Modal -->
<div class="modal-overlay" data-modal-overlay aria-hidden="true"></div>

<div class="modal" role="dialog" aria-modal="true" aria-labelledby="modal-title" tabindex="-1">
  <header class="modal__header">
    <h2 class="modal__title" id="modal-title">Confirmar acción</h2>
    <button class="modal__close btn btn--ghost btn--icon-only" aria-label="Cerrar modal" data-modal-close>
      <span class="btn__icon" aria-hidden="true">
        <svg>...</svg>
      </span>
    </button>
  </header>
  <div class="modal__body">
    <p class="modal__text">¿Estás seguro de que deseas eliminar este elemento? Esta acción no se puede deshacer.</p>
  </div>
  <footer class="modal__footer">
    <button class="btn btn--secondary" data-modal-cancel>Cancelar</button>
    <button class="btn btn--primary btn--danger">Eliminar</button>
  </footer>
</div>
```

## CSS

```css
/* === Overlay === */
.modal-overlay {
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  inset: 0;
  opacity: 0;
  position: fixed;
  transition: opacity 0.3s ease;
  visibility: hidden;
  z-index: var(--z-overlay);
}

.modal-overlay.is-open {
  opacity: 1;
  visibility: visible;
}

/* === Block === */
.modal {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-xl);
  display: flex;
  flex-direction: column;
  left: 50%;
  max-height: 90vh;
  max-width: 32rem;
  opacity: 0;
  position: fixed;
  top: 50%;
  transform: translate(-50%, -50%) scale(0.95);
  transition: opacity 0.3s ease, transform 0.3s ease, visibility 0.3s;
  visibility: hidden;
  width: calc(100% - var(--space-8));
  z-index: var(--z-modal);
}

.modal.is-open {
  opacity: 1;
  transform: translate(-50%, -50%) scale(1);
  visibility: visible;
}

/* === Elements === */
.modal__header {
  align-items: flex-start;
  border-bottom: 1px solid var(--color-border);
  display: flex;
  gap: var(--space-4);
  justify-content: space-between;
  padding: var(--space-4) var(--space-6);
}

.modal__title {
  font-size: var(--font-size-xl);
  font-weight: 600;
  line-height: 1.3;
  margin: 0;
}

.modal__close {
  flex-shrink: 0;
  margin: calc(var(--space-1) * -1) calc(var(--space-2) * -1) 0 0;
}

.modal__body {
  flex: 1;
  overflow-y: auto;
  padding: var(--space-4) var(--space-6);
}

.modal__text {
  color: var(--color-text-muted);
  line-height: 1.6;
  margin: 0;
}

.modal__footer {
  align-items: center;
  border-top: 1px solid var(--color-border);
  display: flex;
  gap: var(--space-3);
  justify-content: flex-end;
  padding: var(--space-4) var(--space-6);
}

/* === Modifiers === */
.modal--sm {
  max-width: 24rem;
}

.modal--lg {
  max-width: 48rem;
}

.modal--fullscreen {
  border-radius: 0;
  height: 100vh;
  max-height: 100vh;
  max-width: 100vw;
  width: 100vw;
}

.modal--danger .modal__header {
  border-bottom-color: var(--color-danger-subtle);
}

.modal--danger .modal__title {
  color: var(--color-danger);
}

/* === Accessibility === */
.modal:focus-visible {
  outline: none;
}

/* === Reduced Motion === */
@media (prefers-reduced-motion: reduce) {
  .modal,
  .modal-overlay {
    transition: none;
  }

  .modal.is-open {
    transform: translate(-50%, -50%) scale(1);
  }
}

/* === Scroll lock en body === */
body.is-modal-open {
  overflow: hidden;
}
```

## Tokens Requeridos

```css
:root {
  --color-surface: #ffffff;
  --color-border: #e2e8f0;
  --color-text-muted: #64748b;
  --color-danger: #dc2626;
  --color-danger-subtle: #fef2f2;

  --font-size-xl: 1.25rem;

  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-6: 1.5rem;
  --space-8: 2rem;

  --radius-lg: 12px;

  --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);

  --z-overlay: 40;
  --z-modal: 50;
}
```

## Checklist

- [ ] `role="dialog"`, `aria-modal="true"`, `aria-labelledby` apuntando al título
- [ ] `.modal-overlay` separado del `.modal` (z-index jerárquico)
- [ ] `prefers-reduced-motion` remueve transiciones
- [ ] `max-height: 90vh` + `overflow-y: auto` en body para scroll interno
- [ ] Footer con botones alineados a la derecha (`justify-content: flex-end`)
- [ ] `.modal--danger` semántico (no `.modal--red`)
- [ ] `body.is-modal-open` para bloquear scroll
- [ ] Focus trap implementado en JS (no en CSS)
- [ ] Botón de cierre con `aria-label`
