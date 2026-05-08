# Naming Conventions

> Convenciones de nombres para clases, archivos, y tokens de diseño.

## Clases CSS

### BEM (recomendado para componentes)
```css
.block { }
.block__element { }
.block--modifier { }
.block__element--modifier { }
```

### SMACSS (recomendado para categorías)
```css
.l-header     /* layout */
.nav          /* module */
.is-active    /* state */
.theme-dark   /* theme */
```

### Prefijos ITCSS (recomendado con pre-procesador)
```css
.o-media      /* object */
.c-card       /* component */
.u-hidden     /* utility */
```

### Estados
```css
.is-active
.is-open
.is-loading
.is-disabled
.has-error
.has-focus
```

### JavaScript hooks
```html
<!-- Nunca uses clases CSS para JS -->
<button class="btn is-active js-toggle-menu">

<!-- Usa data-* -->
<button class="btn is-active" data-js="toggle-menu">
```

## Tokens de Diseño (Custom Properties)

```css
/* ✅ CORRECTO */
:root {
  --color-primary: #2563eb;
  --color-primary-hover: #1d4ed8;
  --color-text: #1f2937;
  --color-text-muted: #6b7280;
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-6: 1.5rem;
  --space-8: 2rem;
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;
  --font-body: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
}
```

## Archivos

```
styles/
├── settings/
│   ├── _colors.css
│   ├── _spacing.css
│   ├── _typography.css
│   └── _index.css
├── generic/
│   ├── _reset.css
│   └── _index.css
├── elements/
│   ├── _headings.css
│   ├── _links.css
│   └── _index.css
├── objects/
│   ├── _media.css
│   ├── _grid.css
│   └── _index.css
├── components/
│   ├── _button.css
│   ├── _card.css
│   ├── _modal.css
│   └── _index.css
└── utilities/
    ├── _spacing.css
    ├── _visibility.css
    └── _index.css
```

### Reglas de archivos
- Prefijo `_` para parciales (Sass/SCSS).
- Todo en minúsculas.
- Palabras separadas por guiones.
- Nunca espacios ni camelCase en nombres de archivo CSS.

## Nombres Prohibidos

```css
/* ❌ Nunca uses estos patrones */
.yellow-box { }          /* presentacional */
.left { }                /* presentacional */
.clearfix { }           /* semánticamente vacío */
#header { }             /* ID para estilos */
.container .box { }     /* nesting innecesario */
```
