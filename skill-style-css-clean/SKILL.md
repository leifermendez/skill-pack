---
name: skill-style-css-clean
description: Auditor de CSS/SCSS para proyectos web. Enforcea mandamientos CSS, metodologías BEM/ITCSS, organización de archivos, performance y accesibilidad. Optimizado para cualquier stack (vanilla, React, Vue, Angular, etc).
compatibility: Framework agnostic. Vanilla CSS, SCSS, Sass, Less, Stylus.
metadata:
  author: builderbot
  version: "1.0"
  tags: "css, scss, bem, itcss, oocss, smacss, clean-code, a11y, performance"
---

# CSS Clean - Los 10 Mandamientos

> **Auditor CSS universal.** Aplica a cualquier proyecto web con CSS, SCSS, Sass o cualquier pre-procesador.
> **Para LLMs pequeños:** Lee el `QUICKSTART.md` (si existe) o salta directo a **Checklist de Cierre**.

## Cuándo Usar
- Crear o auditar hojas de estilo CSS/SCSS
- Refactorizar CSS legacy en desorden
- Definir la estructura de archivos CSS de un proyecto nuevo
- Revisar naming conventions, specificity wars, o código CSS muerto
- Verificar accesibilidad (focus, contraste, motion) en capa de presentación

## Protocolo (4 Pasos Obligatorios)

### 1. ESCANEAR
Lista TODOS los archivos CSS/SCSS del componente, vista o proyecto. Incluye variables, mixins, base, componentes, utilidades.

### 2. AUDITAR
Revisa cada archivo contra los **10 Mandamientos** de abajo.

### 3. CORREGIR
Aplica cambios en este orden:
1. Fix naming (BEM + semántico)
2. Fix specificity (selectores planos)
3. Fix organización (ITCSS)
4. Fix performance (cascada, duplicados)
5. Fix accesibilidad (focus, motion, contraste)

### 4. VALIDAR
Marca cada item del **Checklist de Cierre**. Si falla algo, vuelve al paso 3.

---

# Los 10 Mandamientos del CSS Clean

## 1. NUNCA uses `!important`
> Rompe la cascada natural. Es señal de que perdiste el control de la specificity.

```css
/* ❌ PROHIBIDO */
.button {
  color: white !important;
}

/* ✅ CORRECTO: Aumenta specificity o reestructura */
.btn.btn--primary {
  color: white;
}
```

## 2. Usa BEM para nombrar clases
> Bloque `__` Elemento `--` Modificador. Nunca uses IDs para estilos.

```css
/* ✅ CORRECTO */
.card { }
.card__title { }
.card__body { }
.card--featured { }
.card__body--compact { }

/* ❌ PROHIBIDO */
#card { }
.card .title { }
.card-title { }
```

## 3. Mantén selectores planos (máximo 3 niveles)
> Cada nivel extra multiplica el costo de render y dificulta la reusabilidad.

```css
/* ❌ PROHIBIDO */
header nav ul li a span { }

/* ✅ CORRECTO */
.nav__link-text { }
```

## 4. Agrupa y ordena declaraciones consistentemente
> Orden alfabético o por categorías (Positioning > Box Model > Typography > Visual > Misc). Elige UNO y sèlo.

```css
/* ✅ CORRECTO (alfabético) */
.btn {
  background: #000;
  border: 1px solid #ccc;
  color: #fff;
  display: inline-flex;
  font-size: 1rem;
  padding: 0.5rem 1rem;
}
```

## 5. Usa Custom Properties (variables CSS) para tokens de diseño
> Colores, espaciado, tipografía, sombras, radios. Nunca hardcodees valores mágicos.

```css
/* ✅ CORRECTO */
:root {
  --color-primary: #2563eb;
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-4: 1rem;
  --radius-sm: 4px;
  --radius-md: 8px;
  --font-body: 'Inter', system-ui, sans-serif;
}

.btn--primary {
  background: var(--color-primary);
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  font-family: var(--font-body);
}
```

## 6. Evita selectores de tipo + clase (`ul.nav`)
> Suelta el nombre del tipo. Los selectores de clase puros son más rápidos y reusables.

```css
/* ❌ PROHIBIDO */
ul.nav { }
div.error { }

/* ✅ CORRECTO */
.nav { }
.error { }
```

## 7. Comenta TU lógica, no lo obvio
> Explica decisiones, no declaraciones. Usa secciones con delimitadores para navegación rápida.

```css
/* ✅ CORRECTO */
/* || UTILITIES */
/* || CARDS */

.card {
  /* Fallback for Safari < 14 */
  display: -webkit-flex;
  display: flex;
}
```

## 8. Unidades: `0` sin unidad, decimales con `0` delante

```css
/* ✅ CORRECTO */
margin: 0;
padding: 0;
opacity: 0.8;
font-size: 0.75rem;

/* ❌ PROHIBIDO */
margin: 0px;
opacity: .8;
font-size: .75rem;
```

## 9. Usa shorthand cuando sea posible
> Ahorra líneas y mejora legibilidad. Pero no inventes propiedades que no existen.

```css
/* ✅ CORRECTO */
margin: 0 1rem 2rem;
border: 1px solid #ccc;
font: 100%/1.6 'Inter', sans-serif;

/* ❌ PROHIBIDO */
margin-top: 0;
margin-right: 1rem;
margin-bottom: 2rem;
margin-left: 1rem;
```

## 10. Separa concerns: Estructura vs. Presentación vs. Comportamiento
> CSS puro para presentación. HTML para estructura. JS para comportamiento.
> No uses `style` inline. No uses JS para calcular estilos si puedes usar CSS.

```html
<!-- ❌ PROHIBIDO -->
<div style="color: red;" onclick="changeColor()">

<!-- ✅ CORRECTO -->
<div class="alert alert--error" data-js="color-changer">
```

---

## Organización de Archivos (ITCSS + 7-1)

```
styles/
├── settings/        /* Variables, tokens, config */
│   ├── _colors.css
│   ├── _spacing.css
│   ├── _typography.css
│   └── _index.css   /* @import todos */
├── tools/           /* Mixins, funciones (Sass/SCSS) */
│   └── _index.scss
├── generic/         /* Reset, normalize, box-sizing */
│   ├── _reset.css
│   └── _index.css
├── elements/        /* Estilos base de elementos HTML */
│   ├── _headings.css
│   ├── _links.css
│   └── _index.css
├── objects/         /* Layout patterns: grids, media object */
│   ├── _layout.css
│   └── _index.css
├── components/      /* Componentes UI concretos (BEM) */
│   ├── _button.css
│   ├── _card.css
│   ├── _modal.css
│   └── _index.css
├── utilities/       /* Overrides y helpers de alta specificity */
│   ├── _spacing.css
│   ├── _visibility.css
│   └── _index.css
└── main.css         /* Único punto de entrada */
```

**Regla de compilación:** `main.css` solo importa índices. Nunca importa archivos sueltos directamente.

```css
/* main.css */
@import url('settings/_index.css');
@import url('generic/_index.css');
@import url('elements/_index.css');
@import url('objects/_index.css');
@import url('components/_index.css');
@import url('utilities/_index.css');
```

---

## Formato y Estilo (Google CSS + Consistencia)

### Indentación
- 2 espacios. Nunca tabs. Nunca mezcles.

### Casing
- Todo en minúsculas: selectores, propiedades, valores (excepto strings).
- Colores: shorthand hex `#ebc` cuando sea posible. Siempre minúscula.

### Comillas
- Selectores de atributo: comillas simples.
- URLs: sin comillas.

```css
/* ✅ CORRECTO */
@import url(https://fonts.googleapis.com/css?family=Open+Sans);

html {
  font-family: 'Open Sans', arial, sans-serif;
}

input[type='text'] { }
```

### Separación
- Espacio entre selector y `{`.
- Espacio después de `:`.
- Punto y coma al final de CADA declaración.
- Línea en blanco entre reglas.

```css
/* ✅ CORRECTO */
.card {
  background: #fff;
  border: 1px solid #ccc;
}

.card--dark {
  background: #000;
  color: #fff;
}
```

---

## Performance CSS

| Regla | Mandamiento |
|-------|-------------|
| **Specificity** | Máximo 3 clases por selector. Evita `!important`. |
| **Reflow** | No cambies `width`, `height`, `top`, `left` en animaciones. Usa `transform` y `opacity`. |
| **Repaint** | Prefiere `will-change` con moderación. Remuévelo después. |
| **Duplicados** | Cada declaración debe existir UNA vez. Usa mixins o variables. |
| **Unused CSS** | Purga con herramientas si el proyecto lo permite. |

---

## Accesibilidad (A11y) en CSS

```css
/* ✅ OBLIGATORIO: focus-visible en todo interactivo */
.btn:focus-visible {
  outline: 2px solid var(--color-focus);
  outline-offset: 2px;
}

/* ✅ OBLIGATORIO: NO uses outline: none sin reemplazo */
/* ❌ PROHIBIDO */
.btn {
  outline: none;
}

/* ✅ OBLIGATORIO: Respectar prefers-reduced-motion */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* ✅ OBLIGATORIO: Contraste mínimo 4.5:1 texto normal, 3:1 texto grande/UI */
/* Usa herramientas como WebAIM contrast checker */
```

---

## Checklist de Cierre (Marcar Todos)

- [ ] Sin `!important` en ninguna declaración
- [ ] Clases nombradas con BEM (Block__Element--Modifier)
- [ ] Selectores planos (máximo 3 niveles)
- [ ] Declaraciones ordenadas alfabéticamente o por categoría (consistente)
- [ ] Variables CSS para tokens (colores, spacing, radius, fonts)
- [ ] Sin selectores de tipo + clase (`ul.nav`)
- [ ] Comentarios explican decisiones, no obviedades
- [ ] Unidades: `0` sin unidad, decimales con `0` delante
- [ ] Shorthand properties usadas correctamente
- [ ] Sin estilos inline ni `style="..."`
- [ ] Archivos organizados ITCSS (Settings → Utilities)
- [ ] Indentación de 2 espacios, minúsculas, formato consistente
- [ ] Sin duplicados de declaraciones
- [ ] `focus-visible` en todo elemento interactivo
- [ ] `prefers-reduced-motion` respetado
- [ ] Contraste de colores verificado

---

## Referencias (Para Detalles)

### Metodologías
- `references/methodologies/bem.md` — Los 5 Mandamientos de BEM (Yandex)
- `references/methodologies/itcss.md` — Arquitectura ITCSS (Harry Roberts)
- `references/methodologies/smacss.md` — 5 Categorías SMACSS (Jonathan Snook)

### Anti-Patterns (Qué NUNCA hacer)
- `references/anti-pattern/specificity-wars.md` — Selectores largos y nesting profundo
- `references/anti-pattern/important-abuse.md` — Uso de `!important`
- `references/anti-pattern/inline-styles.md` — Estilos inline
- `references/anti-pattern/id-selectors.md` — IDs para estilos CSS
- `references/anti-pattern/magic-numbers.md` — Números mágicos sin tokens
- `references/anti-pattern/dead-code.md` — Código muerto y CSS no usado
- `references/anti-pattern/universal-overuse.md` — Abuso del selector `*`
- `references/anti-pattern/type-class-selectors.md` — Selectores tipo + clase (`ul.nav`)

### Patterns (Cómo hacerlo bien)
- `references/pattern/button.md` — Patrón Button completo (BEM + A11y)
- `references/pattern/card.md` — Patrón Card con layout variants
- `references/pattern/modal.md` — Patrón Modal / Dialog accesible
- `references/pattern/form.md` — Patrón Form con validación ARIA
- `references/pattern/navbar.md` — Patrón Navbar responsive con skip link
- `references/pattern/tokens.md` — Sistema completo de Design Tokens
- `references/pattern/responsive.md` — Mobile-first + Container Queries
- `references/pattern/a11y-focus.md` — Focus-visible, skip links, focus trap

### Reglas Generales
- `references/naming-conventions.md` — Convenciones de nombres completas
- `references/file-organization.md` — Organización de archivos avanzada (ITCSS + 7-1)
- `references/checklist.md` — Checklist extendido de validación
