# CSS Clean - Quickstart (Para LLMs Pequeños)

> Resumen ultra-compacto de los 10 Mandamientos. Si necesitas detalles, lee `SKILL.md`.

## Protocolo (4 Pasos)

1. **ESCANEAR**: Lista todos los archivos CSS/SCSS.
2. **AUDITAR**: Revisa contra las 5 Reglas Críticas de abajo.
3. **CORREGIR**: Aplica en orden: naming → specificity → organización → performance.
4. **VALIDAR**: Marca el Checklist de Cierre.

---

## Las 5 Reglas Críticas

### 1. Sin `!important` (jamás)
```css
/* ❌ PROHIBIDO */
.button { color: white !important; }

/* ✅ CORRECTO */
.btn.btn--primary { color: white; }
```

### 2. Nombres con BEM
```css
/* Block__Element--Modifier */
.card { }
.card__title { }
.card--featured { }
.card__title--large { }
```

### 3. Selectores planos (máx 3 niveles)
```css
/* ❌ PROHIBIDO */
header nav ul li a span { }

/* ✅ CORRECTO */
.nav__link-text { }
```

### 4. Variables CSS para tokens
```css
:root {
  --color-primary: #2563eb;
  --space-2: 0.5rem;
  --radius-md: 8px;
}

.btn--primary {
  background: var(--color-primary);
  padding: var(--space-2);
  border-radius: var(--radius-md);
}
```

### 5. Accesibilidad mínima
```css
/* focus-visible obligatorio */
.btn:focus-visible {
  outline: 2px solid var(--color-focus);
}

/* prefers-reduced-motion */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Checklist de Cierre (Marcar Todo)

- [ ] Sin `!important`
- [ ] Clases nombradas BEM
- [ ] Selectores planos (≤3 niveles)
- [ ] Variables CSS para colores, spacing, radius, fonts
- [ ] Sin selectores tipo+clase (`ul.nav`)
- [ ] 0 sin unidad, decimales con `0` delante
- [ ] Shorthand properties usadas
- [ ] Sin estilos inline
- [ ] Archivos en orden ITCSS
- [ ] Indentación 2 espacios, minúsculas
- [ ] `focus-visible` en interactivos
- [ ] `prefers-reduced-motion` respetado

---

## ITCSS Resumido (Orden de Archivos)

```
1-settings/     /* Variables */
2-tools/        /* Mixins (SCSS) */
3-generic/      /* Reset, normalize */
4-elements/     /* Estilos base HTML */
5-objects/      /* Layout patterns */
6-components/   /* Componentes BEM */
7-utilities/    /* Helpers, overrides */
main.css        /* Punto único de entrada */
```

## Anti-Patterns Rápidos

| ❌ Anti-Pattern | ✅ Fix |
|----------------|--------|
| `#header { }` | `.header { }` |
| `.nav .item { }` | `.nav__item { }` |
| `margin: 0px;` | `margin: 0;` |
| `opacity: .8;` | `opacity: 0.8;` |
| `.button-green { }` | `.button--theme-primary { }` |
| `<div style="color: red">` | `<div class="alert alert--error">` |
| `* { transition: all; }` | Transiciones solo en elementos que las necesitan |
