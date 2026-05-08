# Pattern: Button (Producción Real)

> Botón completo y realista. CSS puro, sin frameworks. Listo para copiar y usar.

## HTML — Variantes Completas

```html
<!-- === Primario (llamada a la acción) === -->
<button class="btn btn--primary">Guardar cambios</button>
<a class="btn btn--primary" href="/checkout">Continuar</a>

<!-- === Secundario (acción alternativa) === -->
<button class="btn btn--secondary">Cancelar</button>
<button class="btn btn--secondary btn--disabled" disabled>Cancelar</button>

<!-- === Ghost (menos prominente) === -->
<button class="btn btn--ghost">Más opciones</button>

<!-- === Danger (destructivo) === -->
<button class="btn btn--danger">Eliminar cuenta</button>
<button class="btn btn--danger btn--secondary">Eliminar</button>

<!-- === Éxito (confirmación) === -->
<button class="btn btn--success">Verificado</button>

<!-- === Estados === -->
<button class="btn btn--primary btn--loading" aria-busy="true" disabled>
  <span class="btn__spinner" aria-hidden="true"></span>
  <span class="btn__text">Guardando...</span>
</button>

<button class="btn btn--primary" disabled>Procesando</button>

<!-- === Con icono izquierdo === -->
<button class="btn btn--primary btn--icon-left">
  <span class="btn__icon" aria-hidden="true">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
      <polyline points="7 10 12 15 17 10"/>
      <line x1="12" y1="15" x2="12" y2="3"/>
    </svg>
  </span>
  <span class="btn__text">Descargar</span>
</button>

<!-- === Con icono derecho === -->
<button class="btn btn--secondary btn--icon-right">
  <span class="btn__text">Siguiente</span>
  <span class="btn__icon" aria-hidden="true">
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <line x1="5" y1="12" x2="19" y2="12"/>
      <polyline points="12 5 19 12 12 19"/>
    </svg>
  </span>
</button>

<!-- === Icon-only (accesibilidad obligatoria) === -->
<button class="btn btn--ghost btn--icon-only" aria-label="Cerrar panel">
  <span class="btn__icon" aria-hidden="true">
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <line x1="18" y1="6" x2="6" y2="18"/>
      <line x1="6" y1="6" x2="18" y2="18"/>
    </svg>
  </span>
</button>

<!-- === Tamaños === -->
<button class="btn btn--primary btn--xs">Extra small</button>
<button class="btn btn--primary btn--sm">Small</button>
<button class="btn btn--primary">Default</button>
<button class="btn btn--primary btn--lg">Large</button>
<button class="btn btn--primary btn--xl">Extra large</button>

<!-- === Ancho completo === -->
<button class="btn btn--primary btn--full">Añadir al carrito</button>
```

---

## CSS — Completo y Real

```css
/* =========================================
   BUTTON — Componente de producción
   ========================================= */

/* ---------- Block base ---------- */
.btn {
  align-items: center;
  border: 1px solid transparent;
  border-radius: 8px;
  cursor: pointer;
  display: inline-flex;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  font-size: 0.875rem;
  font-weight: 500;
  gap: 0.5rem;
  justify-content: center;
  line-height: 1.25rem;
  padding: 0.5rem 1rem;
  position: relative;
  text-decoration: none;
  transition:
    background-color 150ms cubic-bezier(0.4, 0, 0.2, 1),
    border-color 150ms cubic-bezier(0.4, 0, 0.2, 1),
    color 150ms cubic-bezier(0.4, 0, 0.2, 1),
    box-shadow 150ms cubic-bezier(0.4, 0, 0.2, 1),
    transform 100ms cubic-bezier(0.4, 0, 0.2, 1);
  user-select: none;
  vertical-align: middle;
  white-space: nowrap;
}

/* ---------- Elements ---------- */
.btn__icon {
  display: inline-flex;
  flex-shrink: 0;
  height: 1rem;
  width: 1rem;
}

.btn__icon svg {
  display: block;
  height: 100%;
  width: 100%;
}

.btn__text {
  display: inline;
}

.btn__spinner {
  animation: btn-spin 1s linear infinite;
  border: 2px solid currentColor;
  border-radius: 9999px;
  border-top-color: transparent;
  display: inline-block;
  flex-shrink: 0;
  height: 1rem;
  width: 1rem;
}

@keyframes btn-spin {
  to {
    transform: rotate(360deg);
  }
}

/* ---------- Variantes de tema ---------- */

/* Primary */
.btn--primary {
  background-color: #2563eb;
  border-color: #2563eb;
  color: #ffffff;
}

.btn--primary:hover:not(:disabled) {
  background-color: #1d4ed8;
  border-color: #1d4ed8;
}

.btn--primary:active:not(:disabled) {
  background-color: #1e40af;
  border-color: #1e40af;
  transform: translateY(1px);
}

/* Secondary */
.btn--secondary {
  background-color: #ffffff;
  border-color: #e2e8f0;
  color: #1e293b;
}

.btn--secondary:hover:not(:disabled) {
  background-color: #f8fafc;
  border-color: #cbd5e1;
  color: #0f172a;
}

.btn--secondary:active:not(:disabled) {
  background-color: #f1f5f9;
  border-color: #94a3b8;
  transform: translateY(1px);
}

/* Ghost */
.btn--ghost {
  background-color: transparent;
  border-color: transparent;
  color: #2563eb;
}

.btn--ghost:hover:not(:disabled) {
  background-color: #eff6ff;
}

.btn--ghost:active:not(:disabled) {
  background-color: #dbeafe;
  transform: translateY(1px);
}

/* Danger */
.btn--danger {
  background-color: #dc2626;
  border-color: #dc2626;
  color: #ffffff;
}

.btn--danger:hover:not(:disabled) {
  background-color: #b91c1c;
  border-color: #b91c1c;
}

.btn--danger:active:not(:disabled) {
  background-color: #991b1b;
  border-color: #991b1b;
  transform: translateY(1px);
}

/* Danger Secondary */
.btn--danger.btn--secondary {
  background-color: #ffffff;
  border-color: #fecaca;
  color: #dc2626;
}

.btn--danger.btn--secondary:hover:not(:disabled) {
  background-color: #fef2f2;
  border-color: #fca5a5;
}

/* Success */
.btn--success {
  background-color: #16a34a;
  border-color: #16a34a;
  color: #ffffff;
}

.btn--success:hover:not(:disabled) {
  background-color: #15803d;
  border-color: #15803d;
}

.btn--success:active:not(:disabled) {
  background-color: #166534;
  transform: translateY(1px);
}

/* ---------- Estados compartidos ---------- */

.btn:disabled,
.btn--disabled {
  cursor: not-allowed;
  opacity: 0.5;
  pointer-events: none;
}

.btn--loading {
  cursor: wait;
}

/* ---------- Tamaños ---------- */

.btn--xs {
  font-size: 0.75rem;
  gap: 0.375rem;
  line-height: 1rem;
  padding: 0.375rem 0.625rem;
}

.btn--xs .btn__icon {
  height: 0.75rem;
  width: 0.75rem;
}

.btn--sm {
  font-size: 0.8125rem;
  gap: 0.375rem;
  line-height: 1.125rem;
  padding: 0.4375rem 0.875rem;
}

.btn--sm .btn__icon {
  height: 0.875rem;
  width: 0.875rem;
}

.btn--lg {
  font-size: 1rem;
  gap: 0.625rem;
  line-height: 1.5rem;
  padding: 0.625rem 1.25rem;
}

.btn--lg .btn__icon {
  height: 1.125rem;
  width: 1.125rem;
}

.btn--xl {
  font-size: 1.125rem;
  gap: 0.75rem;
  line-height: 1.75rem;
  padding: 0.75rem 1.5rem;
}

.btn--xl .btn__icon {
  height: 1.25rem;
  width: 1.25rem;
}

/* ---------- Layout modifiers ---------- */

.btn--icon-only {
  padding: 0.5rem;
}

.btn--icon-only.btn--xs {
  padding: 0.375rem;
}

.btn--icon-only.btn--sm {
  padding: 0.4375rem;
}

.btn--icon-only.btn--lg {
  padding: 0.625rem;
}

.btn--icon-only.btn--xl {
  padding: 0.75rem;
}

.btn--icon-only .btn__icon {
  height: 1.125rem;
  width: 1.125rem;
}

.btn--icon-left {
  flex-direction: row;
}

.btn--icon-right {
  flex-direction: row-reverse;
}

.btn--full {
  display: flex;
  width: 100%;
}

/* ---------- Accessibility ---------- */

.btn:focus-visible {
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.3);
  outline: none;
}

.btn--danger:focus-visible {
  box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.3);
}

.btn--secondary:focus-visible {
  box-shadow: 0 0 0 3px rgba(148, 163, 184, 0.4);
}

.btn--ghost:focus-visible {
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.25);
}

/* ---------- Dark theme ---------- */

@media (prefers-color-scheme: dark) {
  .btn--primary {
    background-color: #3b82f6;
    border-color: #3b82f6;
  }

  .btn--primary:hover:not(:disabled) {
    background-color: #2563eb;
    border-color: #2563eb;
  }

  .btn--primary:active:not(:disabled) {
    background-color: #1d4ed8;
    border-color: #1d4ed8;
  }

  .btn--secondary {
    background-color: #1e293b;
    border-color: #334155;
    color: #f1f5f9;
  }

  .btn--secondary:hover:not(:disabled) {
    background-color: #334155;
    border-color: #475569;
  }

  .btn--ghost {
    color: #60a5fa;
  }

  .btn--ghost:hover:not(:disabled) {
    background-color: rgba(59, 130, 246, 0.15);
  }

  .btn:focus-visible {
    box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.35);
  }
}

/* ---------- Reduced motion ---------- */

@media (prefers-reduced-motion: reduce) {
  .btn {
    transition: none;
  }

  .btn:active:not(:disabled) {
    transform: none;
  }

  .btn__spinner {
    animation: none;
    border-color: currentColor;
    border-top-color: currentColor;
    opacity: 0.6;
  }
}
```

---

## Tokens Requeridos (Custom Properties opcionales)

Si prefieres usar variables CSS en vez de valores hardcodeados, estos son los tokens equivalentes:

```css
:root {
  --btn-primary-bg: #2563eb;
  --btn-primary-bg-hover: #1d4ed8;
  --btn-primary-bg-active: #1e40af;
  --btn-primary-color: #ffffff;

  --btn-secondary-bg: #ffffff;
  --btn-secondary-bg-hover: #f8fafc;
  --btn-secondary-border: #e2e8f0;
  --btn-secondary-border-hover: #cbd5e1;
  --btn-secondary-color: #1e293b;

  --btn-ghost-color: #2563eb;
  --btn-ghost-bg-hover: #eff6ff;

  --btn-danger-bg: #dc2626;
  --btn-danger-bg-hover: #b91c1c;

  --btn-success-bg: #16a34a;
  --btn-success-bg-hover: #15803d;

  --btn-disabled-opacity: 0.5;
  --btn-focus-ring: 0 0 0 3px rgba(37, 99, 235, 0.3);
  --btn-focus-ring-danger: 0 0 0 3px rgba(220, 38, 38, 0.3);

  --btn-radius: 8px;
  --btn-font: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
```

---

## Checklist de Validación

- [ ] BEM plano: `.btn`, `.btn__icon`, `.btn__text`, `.btn--primary`, `.btn--lg`
- [ ] Sin nesting de selectores CSS
- [ ] `:hover`, `:active` y `:disabled` implementados
- [ ] `:focus-visible` con `box-shadow` (no `outline: none` solo)
- [ ] Variantes semánticas: primary, secondary, ghost, danger, success
- [ ] Tamaños proporcionales: xs, sm, default, lg, xl
- [ ] Icon-left, icon-right, icon-only con `aria-label`
- [ ] Spinner animado con `animation` + `@keyframes`
- [ ] `.btn--loading` fija cursor y previene clicks
- [ ] `user-select: none` y `white-space: nowrap`
- [ ] Transiciones con `cubic-bezier` real (ease-out)
- [ ] `:active` tiene `transform: translateY(1px)` (feedback táctil)
- [ ] Dark mode con `@media (prefers-color-scheme: dark)`
- [ ] `prefers-reduced-motion` remueve animaciones
- [ ] Funciona con `<button>` y `<a>`
- [ ] `pointer-events: none` en disabled para seguridad
