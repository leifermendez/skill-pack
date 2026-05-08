# Organización de Archivos Avanzada

## ITCSS + 7-1 (Recomendado)

```
styles/
├── 1-settings/
│   ├── _colors.css
│   ├── _spacing.css
│   ├── _typography.css
│   ├── _z-index.css
│   ├── _breakpoints.css
│   ├── _shadows.css
│   └── _index.css
│
├── 2-tools/
│   ├── _mixins.scss
│   ├── _functions.scss
│   └── _index.scss
│
├── 3-generic/
│   ├── _reset.css
│   ├── _normalize.css
│   ├── _box-sizing.css
│   └── _index.css
│
├── 4-elements/
│   ├── _page.css
│   ├── _headings.css
│   ├── _links.css
│   ├── _lists.css
│   ├── _images.css
│   └── _index.css
│
├── 5-objects/
│   ├── _media.css
│   ├── _grid.css
│   ├── _layout.css
│   ├── _list-bare.css
│   └── _index.css
│
├── 6-components/
│   ├── _button.css
│   ├── _card.css
│   ├── _modal.css
│   ├── _form.css
│   ├── _nav.css
│   ├── _alert.css
│   ├── _badge.css
│   ├── _table.css
│   └── _index.css
│
├── 7-utilities/
│   ├── _spacing.css
│   ├── _visibility.css
│   ├── _text.css
│   ├── _display.css
│   ├── _colors.css
│   ├── _flex.css
│   └── _index.css
│
└── main.css
```

## Convenciones de Numeración

- Los prefijos numéricos (`1-`, `2-`, etc.) aseguran orden visual en el explorador.
- El orden numérico refleja el orden de importación obligatorio.
- Sin números: usar nombres de carpeta claros y un `main.css` que importe en orden.

## Archivos Índice

Cada carpeta tiene un `_index.css` que importa los archivos de esa capa:

```css
/* 1-settings/_index.css */
@import '_colors.css';
@import '_spacing.css';
@import '_typography.css';
@import '_z-index.css';
@import '_breakpoints.css';
@import '_shadows.css';
```

## Punto de Entrada Único

```css
/* main.css */
@import url('1-settings/_index.css');
@import url('2-tools/_index.css');
@import url('3-generic/_index.css');
@import url('4-elements/_index.css');
@import url('5-objects/_index.css');
@import url('6-components/_index.css');
@import url('7-utilities/_index.css');
```

## Para Proyectos Grandes (Multi-page)

```
styles/
├── core/              /* ITCSS completo */
│   ├── settings/
│   ├── generic/
│   ├── elements/
│   ├── objects/
│   ├── components/
│   └── utilities/
├── themes/
│   ├── _light.css
│   ├── _dark.css
│   └── _index.css
├── pages/
│   ├── _home.css
│   ├── _product.css
│   ├── _checkout.css
│   └── _index.css
└── main.css
```

```css
/* main.css */
@import 'core/main.css';
@import 'themes/_index.css';
@import 'pages/_index.css';
```

## Con Pre-procesador (SCSS)

```scss
// main.scss
@use 'settings';
@use 'tools';
@use 'generic';
@use 'elements';
@use 'objects';
@use 'components';
@use 'utilities';

// Con namespaces
@use 'settings' as s;

.card {
  background: s.$color-primary;
}
```

## Para Frameworks (React, Vue, Svelte)

```
src/
├── styles/
│   ├── settings/
│   ├── generic/
│   ├── elements/
│   ├── objects/
│   ├── components/      /* SOLO componentes globales */
│   ├── utilities/
│   └── main.css
└── components/
    ├── Button/
    │   ├── Button.tsx
    │   ├── Button.css    /* scoped al componente */
    │   └── Button.test.tsx
    └── Card/
        ├── Card.tsx
        ├── Card.css
        └── Card.test.tsx
```

**Regla**: Componentes globales (usados en >3 lugares) van en `styles/components/`. Componentes locales van junto al componente.
