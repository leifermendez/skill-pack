# ITCSS (Inverted Triangle CSS)

> Arquitectura de CSS creada por Harry Roberts.
> Ordena CSS de lo más genérico (y de baja specificity) a lo más específico (y de alta specificity).

## La Pirámide Invertida

```
         ^
        / \
       /   \     UTILITIES     (máxima specificity, !important permitido)
      /-----\
     /       \   COMPONENTS    (clases concretas, BEM)
    /---------\
   /           \  OBJECTS      (patrones de layout, sin cosmética)
  /-------------\
 /               \ ELEMENTS     (estilos base de HTML)
/-----------------\
       |||
    GENERIC         (reset, normalize, box-sizing)
    --------
    SETTINGS        (variables, config, sin CSS compilado)
```

## Las 7 Capas

### 1. Settings
Variables, tokens de diseño, breakpoints. No genera CSS compilado.

```css
:root {
  --color-primary: #2563eb;
  --space-1: 0.25rem;
  --breakpoint-md: 768px;
}
```

### 2. Tools
Mixins y funciones. No genera CSS compilado (en Sass/SCSS).

```scss
@mixin respond-to($breakpoint) {
  @media (min-width: $breakpoint) { @content; }
}
```

### 3. Generic
Reset, normalize, box-sizing. Afecta a TODO.

```css
*, *::before, *::after { box-sizing: border-box; }
```

### 4. Elements
Estilos base para elementos HTML sin clases.

```css
body { font-family: var(--font-body); line-height: 1.6; }
h1, h2, h3 { font-weight: 700; }
a { color: var(--color-primary); }
```

### 5. Objects
Patrones de layout reutilizables (media object, grid, flex layouts). Sin color, sin fuentes.

```css
.o-media { display: flex; align-items: flex-start; }
.o-media__body { flex: 1; }
.o-grid { display: grid; gap: var(--space-4); }
```

### 6. Components
Componentes UI concretos. Aquí aplicas BEM.

```css
.c-card { border: 1px solid var(--color-border); border-radius: var(--radius-md); }
.c-card__title { font-size: 1.25rem; }
```

### 7. Utilities
Helpers de alta specificity. Overrides finales. Aquí SÍ puedes usar `!important` (es la única capa).

```css
.u-hidden { display: none !important; }
.u-text-center { text-align: center !important; }
.u-sr-only { /* screen reader only */ }
```

## Reglas de ITCSS

1. **Specificity solo sube**: No puedes bajar de specificity a medida que avanzas en el triángulo.
2. **Nunca importes una capa inferior en una superior**: `components/` no debe importar `elements/`.
3. **Prefijos opcionales**: `o-` objects, `c-` components, `u-` utilities, `t-` themes.
4. **Solo un punto de entrada**: `main.css` o `main.scss`.

## Import Order (obligatorio)

```scss
// main.scss
@import 'settings';
@import 'tools';
@import 'generic';
@import 'elements';
@import 'objects';
@import 'components';
@import 'utilities';
```

## Sin SCSS / Pre-procesador

Con CSS puro, cada capa es un archivo importado:

```css
/* main.css */
@import url('settings.css');
@import url('generic.css');
@import url('elements.css');
@import url('objects.css');
@import url('components.css');
@import url('utilities.css');
```
