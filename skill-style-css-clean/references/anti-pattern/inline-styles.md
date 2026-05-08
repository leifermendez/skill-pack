# Anti-Pattern: Inline Styles

> Atributo `style="..."` en elementos HTML que mezcla presentación con estructura.

## El Problema

```html
<!-- ❌ PROHIBIDO -->
<div style="color: red; margin-top: 10px; font-size: 14px;">
  Error message
</div>
```

### Impacto
- **No cacheable**: El navegador no puede cachear estilos inline.
- **Specificity infinita**: Solo `!important` en CSS externo puede sobreescribirlos.
- **Difícil de mantener**: Cambios requieren editar HTML en múltiples lugares.
- **No reutilizable**: El mismo estilo debe repetirse en cada elemento.
- **Mezcla de concerns**: Presentación en la capa de estructura.

---

## Causa Raíz
- CMS que genera HTML con estilos inline.
- WYSIWYG editors (TinyMCE, CKEditor).
- Email templates (aquí SÍ es necesario por compatibilidad).
- Desarrolladores backend inyectando estilos.
- JavaScript calculando estilos dinámicamente.

---

## Fix

### 1. Mover a clases
```html
<!-- ✅ CORRECTO -->
<div class="alert alert--error alert--spaced">
  Error message
</div>
```

```css
.alert--error {
  color: var(--color-error);
  margin-top: var(--space-2);
  font-size: var(--font-size-sm);
}
```

### 2. Para contenido dinámico (JS)
```js
// ❌ PROHIBIDO
el.style.color = 'red';

// ✅ CORRECTO: setAttribute de clase
el.classList.add('alert--error');

// ✅ CORRECTO: CSS custom properties
el.style.setProperty('--dynamic-color', userColor);
```

```css
.dynamic-element {
  color: var(--dynamic-color, var(--color-primary));
}
```

### 3. Email templates (excepción)
> En email HTML, inline styles son obligatorios por compatibilidad con clientes de correo. Usa un inliner (Premailer, Juice) en build time.

---

## Regla
> **Nunca** escribas `style="..."` a mano en código fuente. Si una herramienta lo genera, purgalo en build time.
