# Checklist Extendido de CSS Clean

## A. Naming y Estructura

- [ ] Nombres de clases son semánticos, no presentacionales
  - ✅ `btn--primary`, `card--featured`
  - ❌ `btn-blue`, `big-card`, `left-sidebar`

- [ ] Usa BEM consistentemente
  - `.block__element--modifier`
  - No anides más de un nivel de elemento
  - No uses IDs (`#header`)

- [ ] Sin selectores de tipo + clase
  - ❌ `ul.nav`, `div.error`
  - ✅ `.nav`, `.error`

## B. Specificity y Cascada

- [ ] Máximo 3 clases por selector
  - ❌ `.header .nav .list .item .link`
  - ✅ `.nav__link`

- [ ] Sin `!important` (excepto utilities ITCSS)

- [ ] Estados aplicados al módulo, no sueltos
  - ✅ `.btn.is-active`
  - ❌ `.is-active`

## C. Formato

- [ ] Indentación: 2 espacios
- [ ] Minúsculas en todo: selectores, propiedades, valores
- [ ] Hex en minúscula, shorthand cuando sea posible
  - ✅ `#ebc` (en vez de `#eebbcc`)

- [ ] 0 sin unidad
  - ✅ `margin: 0`
  - ❌ `margin: 0px`

- [ ] Decimales con 0 delante
  - ✅ `0.8rem`
  - ❌ `.8rem`

- [ ] Punto y coma al final de cada declaración
- [ ] Línea en blanco entre reglas
- [ ] Espacio después de `:`
- [ ] Espacio antes de `{`
- [ ] `{` en la misma línea del selector

## D. Declaraciones

- [ ] Ordenadas alfabéticamente O por categorías (consistente)
- [ ] Shorthand properties cuando sea posible
  - ✅ `margin: 0 1rem 2rem`
  - ❌ `margin-top`, `margin-right`, etc.

- [ ] Variables CSS para tokens
  - Colores, spacing, radius, fonts, shadows, breakpoints

## E. Organización de Archivos

- [ ] ITCSS u otra metodología documentada
- [ ] Un solo punto de entrada (`main.css`)
- [ ] Índices por carpeta
- [ ] Sin imports circulares

## F. Performance

- [ ] Sin duplicados de declaraciones
- [ ] Sin selectores universales (`*`) con propiedades costosas
- [ ] Animaciones con `transform` y `opacity` preferidas
- [ ] `will-change` solo donde se necesita, removido después
- [ ] Sin estilos inline
- [ ] Sin `@import` síncrono en producción (usar bundler)

## G. Accesibilidad (A11y)

- [ ] `focus-visible` en todo elemento interactivo
  ```css
  .btn:focus-visible {
    outline: 2px solid var(--color-focus);
    outline-offset: 2px;
  }
  ```

- [ ] Sin `outline: none` sin reemplazo

- [ ] `prefers-reduced-motion` respetado
  ```css
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
    }
  }
  ```

- [ ] Contraste de colores verificado
  - Texto normal: mínimo 4.5:1
  - Texto grande / UI: mínimo 3:1

- [ ] No depende solo de color para transmitir información
  - ✅ `.is-error` con borde + icono + color
  - ❌ Solo `color: red`

## H. Comentarios

- [ ] Explican decisiones, no obviedades
  ```css
  /* Fallback for Safari < 14 */
  display: -webkit-flex;
  display: flex;
  ```

- [ ] Secciones con delimitadores
  ```css
  /* || CARDS */
  /* || BUTTONS */
  /* || UTILITIES */
  ```

## I. Mantenimiento

- [ ] Sin código muerto (comentado o sin usar)
- [ ] Sin `z-index: 9999` (usa sistema de capas)
- [ ] Media queries agrupadas por breakpoint, no dispersas
- [ ] Print styles considerados

## J. Frameworks / Componentes

- [ ] CSS scoped cuando sea posible (CSS Modules, scoped Vue, etc.)
- [ ] Nombres de clase únicos para evitar colisiones
- [ ] Custom properties para theming
