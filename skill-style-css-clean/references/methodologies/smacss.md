# SMACSS (Scalable and Modular Architecture for CSS)

> Creado por Jonathan Snook.
> Divide CSS en 5 categorías para organizar pensamiento y código.

## Las 5 Categorías

### 1. Base
Estilos por defecto para elementos HTML. Sin clases.

```css
body { font-family: sans-serif; }
a { color: #069; text-decoration: none; }
a:hover { text-decoration: underline; }
```

### 2. Layout
Divide la página en secciones. Prefijo `l-`.

```css
.l-header { width: 100%; }
.l-sidebar { width: 25%; float: left; }
.l-main { width: 75%; float: left; }
```

### 3. Module
Componentes reutilizables. La mayor parte del CSS.

```css
.btn { }
.card { }
.modal { }
```

### 4. State
Cambia la apariencia de un layout o module. Prefijo `is-` o `has-`.

```css
.is-hidden { display: none; }
.is-active { font-weight: bold; }
.is-collapsed { height: 0; overflow: hidden; }
```

### 5. Theme
Colores, tipografías, bordes definidos por temas.

```css
.theme--dark { background: #111; color: #eee; }
.theme--dark .btn { background: #333; color: #fff; }
```

## Naming Conventions SMACSS

| Categoría | Prefijo | Ejemplo |
|-----------|---------|---------|
| Layout | `l-` | `.l-header`, `.l-grid` |
| Module | sin prefijo | `.btn`, `.card` |
| State | `is-`, `has-` | `.is-active`, `.has-error` |
| Theme | `theme-` | `.theme-dark` |

## Diferencias con BEM

- SMACSS es **categórico**: separa por función (base, layout, module, state, theme).
- BEM es **nominal**: separa por estructura (block, element, modifier).

**Puedes combinarlos**:

```css
/* Module con BEM + State con SMACSS */
.btn { }                /* module */
.btn__icon { }          /* BEM element */
.btn--primary { }       /* BEM modifier */
.btn.is-active { }      /* SMACSS state */
.btn.is-disabled { }    /* SMACSS state */
```

## Regla de Estado

Un estado SIEMPRE depende de un módulo o layout. Nunca es independiente.

```css
/* ✅ CORRECTO */
.nav.is-open { }
.btn.is-loading { }

/* ❌ PROHIBIDO: estado suelto */
.is-open { }
```

## Ejemplo Completo

```html
<header class="l-header">
  <nav class="nav is-open">
    <ul class="nav__list">
      <li class="nav__item is-active">
        <a class="nav__link" href="/">Home</a>
      </li>
      <li class="nav__item">
        <a class="nav__link" href="/about">About</a>
      </li>
    </ul>
  </nav>
</header>
```
