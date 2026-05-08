# BEM (Block Element Modifier)

> Estrategia de naming para clases CSS creada por el equipo de Yandex.
> **Mandamiento fundamental:** Todo es una clase y nada está anidado.

## Los 5 Mandamientos de BEM

### 1. Un Block es una entidad independiente
> Tiene significado por sí sola. Puede aparecer en cualquier lugar de la página.

```css
/* ✅ Blocks válidos */
.header { }
.container { }
.menu { }
.checkbox { }
.input { }
.card { }
.button { }
```

### 2. Un Element solo existe dentro de su Block
> No tiene significado independiente. Está semánticamente ligado a su block.

```css
/* ✅ Elements */
.menu__item { }
.list__item { }
.checkbox__caption { }
.header__title { }
```

```html
<!-- ❌ PROHIBIDO: Elemento fuera de su block -->
<div class="menu__item">Solo</div>

<!-- ✅ CORRECTO: Siempre dentro del block -->
<ul class="menu">
  <li class="menu__item">Item</li>
</ul>
```

### 3. Un Modifier es un flag que cambia apariencia o comportamiento
> Se usa para temas, estados, tamaños, colores semanticos.

```css
/* ✅ Modifiers de block */
.button--disabled { }
.button--primary { }
.card--featured { }
.menu--theme-dark { }

/* ✅ Modifiers de element */
.menu__item--active { }
.card__title--large { }
```

```html
<!-- ✅ Block + Modifier -->
<button class="button button--primary">Primary</button>
<button class="button button--disabled">Disabled</button>

<!-- ✅ Block + Element + Modifier -->
<li class="menu__item menu__item--active">Active</li>
```

### 4. NUNCA anides selectores
> Todo es una clase. La specificity debe ser plana y predecible.

```css
/* ❌ PROHIBIDO: nesting rompe BEM */
.menu .menu__item { }
.card .card__title { }

/* ✅ CORRECTO: specificity plana */
.menu { }
.menu__item { }
.card { }
.card__title { }
```

### 5. Un Block NUNCA modifica otro Block
> Cada block es independiente. Si necesitas influir, usa mix.

```css
/* ❌ PROHIBIDO: Header sobreescribe Nav */
.header .nav { background: red; }

/* ✅ CORRECTO: mix de clases en HTML */
<!-- nav es block independiente, header es otro block -->
<header class="header">
  <nav class="nav nav--in-header"></nav>
</header>
```

---

## Sintaxis Oficial

```
.block                        /* Block */
.block__element              /* Element */
.block--modifier            /* Modifier de block */
.block--modifier-value      /* Modifier con valor */
.block__element--modifier   /* Modifier de element */
```

### Ejemplos con valor
```css
.button--size-big { }
.button--theme-primary { }
.menu--size-large { }
```

```html
<button class="button button--theme-primary button--size-big">
  Big Primary Button
</button>
```

---

## Reglas de Nesting (HTML)

### No más de 1 nivel de elemento
```html
<!-- ❌ PROHIBIDO: elementos anidados con BEM -->
<div class="card">
  <div class="card__header">
    <h2 class="card__header__title"></h2>
  </div>
</div>

<!-- ✅ CORRECTO: máximo 1 nivel de element -->
<div class="card">
  <div class="card__header">
    <h2 class="card__title"></h2>
  </div>
</div>
```

### Elementos pueden estar en cualquier orden
```html
<!-- ✅ Correcto: elementos no necesitan orden jerárquico -->
<div class="card">
  <h2 class="card__title"></h2>
  <img class="card__image" />
  <p class="card__text"></p>
</div>
```

---

## Mix (Múltiples Blocks)

```html
<!-- ✅ CORRECTO: mezclar blocks independientes -->
<div class="card">
  <header class="card__header badge">
    <h2 class="card__title"></h2>
    <span class="badge__text">NEW</span>
  </header>
</div>
```

`card__header` es element de `card`. `badge` es block independiente. `badge__text` es element de `badge`.

---

## Prohibiciones Absolutas

| ❌ Prohibido | ✅ Alternativa |
|-------------|---------------|
| IDs para estilos (`#header`) | `.header` (block) |
| Selectores de tipo + clase (`ul.nav`) | `.nav` (block) |
| Nesting CSS (`.nav .item`) | `.nav__item` (element) |
| Modifiers sueltos (`.is-active`) | `.nav__item--active` |
| Más de 2 guiones bajos (`__ __`) | Refactorizar a nuevo block |
| Estilos inline (`style=""`) | Clases BEM |
| Nombres presentacionales (`.red`, `.big`) | `.button--theme-primary`, `.button--size-big` |

---

## Sass / SCSS con BEM

```scss
// ✅ Usa nesting de Sass pero compila a plano
.button {
  display: inline-block;
  padding: 0.5rem 1rem;

  &__icon {
    margin-right: 0.5rem;
  }

  &--primary {
    background: blue;
    color: white;
  }

  &--disabled {
    opacity: 0.5;
    pointer-events: none;
  }
}

// Compila a:
// .button { ... }
// .button__icon { ... }
// .button--primary { ... }
// .button--disabled { ... }
```

```scss
// ✅ Con @at-root (versión explícita)
.block {
  @at-root #{&}__element {
    // styles
  }
  @at-root #{&}--modifier {
    // styles
  }
}
```

---

## Ejemplo Completo: GitHub Button

```html
<button class="button">
  Normal button
</button>
<button class="button button--state-success">
  Success button
</button>
<button class="button button--state-danger">
  Danger button
</button>
```

```css
.button {
  display: inline-block;
  border-radius: 3px;
  padding: 7px 12px;
  border: 1px solid #D5D5D5;
  background-image: linear-gradient(#EEE, #DDD);
  font: 700 13px/18px Helvetica, arial;
}

.button--state-success {
  color: #FFF;
  background: #569E3D linear-gradient(#79D858, #569E3D) repeat-x;
  border-color: #4A993E;
}

.button--state-danger {
  color: #900;
}
```

---

## Beneficios

### Modularidad
Los estilos de un block nunca dependen de otros elementos de la página.

### Reusabilidad
Puedes mover un block de una página a otra sin romper nada.

### Estructura
El HTML y CSS tienen una estructura predecible que cualquier desarrollador puede entender.

---

## Preguntas Frecuentes

### ¿Puedo cambiar los guiones y underscores?
> Sí, siendo consistente. BEM recomienda `__` y `--`, pero puedes usar otros delimitadores como `_` para elementos o `-` para modifiers. Lo importante es la **separación de conceptos**.

### ¿Cuándo es un block vs element?
> Si la entidad puede existir sola → **Block**. Si solo tiene sentido dentro de otra → **Element**.

### ¿Y los estados (active, disabled, loading)?
> Usa **modifiers**: `.button--disabled`, `.menu__item--active`.

### ¿Puedo anidar blocks dentro de blocks?
> Sí. Un block puede contener otros blocks. Pero no uses el padre para estilizar al hijo.

```html
<!-- ✅ Correcto: card contiene button (block independiente) -->
<div class="card">
  <button class="button button--primary">Go</button>
</div>
```
