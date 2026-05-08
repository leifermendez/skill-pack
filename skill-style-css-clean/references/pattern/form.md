# Pattern: Form (BEM)

> Formulario accesible con fieldsets, labels, errores y estados de validación.

## HTML

```html
<form class="form" novalidate>
  <fieldset class="form__fieldset">
    <legend class="form__legend">Información personal</legend>

    <div class="form__group">
      <label class="form__label" for="name">Nombre completo</label>
      <input class="form__input" id="name" name="name" type="text" required aria-describedby="name-error" />
      <span class="form__error" id="name-error" role="alert" aria-live="assertive"></span>
    </div>

    <div class="form__group">
      <label class="form__label" for="email">Correo electrónico</label>
      <input class="form__input form__input--error" id="email" name="email" type="email" required aria-describedby="email-error" aria-invalid="true" />
      <span class="form__error form__error--visible" id="email-error" role="alert" aria-live="assertive">
        Introduce un correo válido
      </span>
    </div>

    <div class="form__group form__group--inline">
      <label class="form__label" for="country">País</label>
      <div class="form__select-wrapper">
        <select class="form__select" id="country" name="country">
          <option value="">Selecciona...</option>
          <option value="es">España</option>
          <option value="mx">México</option>
        </select>
      </div>
    </div>

    <div class="form__group">
      <label class="form__label">
        <input class="form__checkbox" name="terms" type="checkbox" required />
        <span class="form__checkbox-label">Acepto los términos y condiciones</span>
      </label>
    </div>
  </fieldset>

  <div class="form__actions">
    <button class="btn btn--secondary" type="button">Cancelar</button>
    <button class="btn btn--primary" type="submit">Enviar</button>
  </div>
</form>
```

## CSS

```css
/* === Block === */
.form {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

/* === Elements === */
.form__fieldset {
  border: 0;
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  margin: 0;
  padding: 0;
}

.form__legend {
  font-size: var(--font-size-lg);
  font-weight: 600;
  margin-bottom: var(--space-2);
  padding: 0;
}

.form__group {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.form__group--inline {
  align-items: center;
  flex-direction: row;
  gap: var(--space-3);
}

.form__label {
  color: var(--color-text);
  font-size: var(--font-size-sm);
  font-weight: 500;
}

.form__input,
.form__select {
  appearance: none;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  color: var(--color-text);
  font-family: inherit;
  font-size: var(--font-size-base);
  line-height: 1.5;
  padding: var(--space-2) var(--space-3);
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
  width: 100%;
}

.form__input:hover,
.form__select:hover {
  border-color: var(--color-border-hover);
}

.form__input:focus-visible,
.form__select:focus-visible {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px var(--color-focus);
  outline: none;
}

.form__input::placeholder {
  color: var(--color-text-placeholder);
}

.form__input--error {
  border-color: var(--color-danger);
}

.form__input--error:focus-visible {
  border-color: var(--color-danger);
  box-shadow: 0 0 0 3px var(--color-danger-focus);
}

.form__select-wrapper {
  position: relative;
  width: 100%;
}

.form__select-wrapper::after {
  border-color: var(--color-text-muted) transparent transparent;
  border-style: solid;
  border-width: 5px 5px 0;
  content: '';
  pointer-events: none;
  position: absolute;
  right: var(--space-3);
  top: 50%;
  transform: translateY(-50%);
}

.form__error {
  color: var(--color-danger);
  display: none;
  font-size: var(--font-size-sm);
  margin-top: var(--space-1);
}

.form__error--visible {
  display: block;
}

.form__checkbox {
  accent-color: var(--color-primary);
  height: 1.125em;
  margin: 0;
  width: 1.125em;
}

.form__checkbox-label {
  color: var(--color-text);
  font-size: var(--font-size-sm);
}

.form__actions {
  align-items: center;
  display: flex;
  gap: var(--space-3);
  justify-content: flex-end;
}

/* === Responsive === */
@media (max-width: 640px) {
  .form__group--inline {
    flex-direction: column;
    align-items: stretch;
  }

  .form__actions {
    flex-direction: column-reverse;
  }

  .form__actions .btn {
    width: 100%;
  }
}
```

## Tokens Requeridos

```css
:root {
  --color-surface: #ffffff;
  --color-border: #e2e8f0;
  --color-border-hover: #cbd5e1;
  --color-text: #1e293b;
  --color-text-placeholder: #94a3b8;
  --color-text-muted: #64748b;
  --color-primary: #2563eb;
  --color-danger: #dc2626;
  --color-focus: #bfdbfe;
  --color-danger-focus: #fecaca;

  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;

  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-6: 1.5rem;

  --radius-md: 8px;
}
```

## Checklist

- [ ] `<label>` explícito con `for` apuntando al input
- [ ] `aria-describedby` en input apuntando al mensaje de error
- [ ] `aria-invalid="true"` cuando hay error
- [ ] `role="alert"` + `aria-live="assertive"` en errores
- [ ] `novalidate` en `<form>` para controlar validación con JS
- [ ] Errores ocultos por defecto (`.form__error`), visibles con modifier (`.form__error--visible`)
- [ ] `:focus-visible` en inputs con box-shadow tokenizado
- [ ] Checkbox usa `accent-color` nativo
- [ ] `.form__actions` usa `flex-direction: column-reverse` en mobile para accesibilidad (botón primario al final = más cerca del pulgar)
