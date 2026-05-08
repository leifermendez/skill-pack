# Anti-Pattern: Type + Class Selectors

> Usar el nombre del elemento HTML junto a una clase (`ul.nav`, `div.error`).

## El Problema

```css
/* ❌ PROHIBIDO */
ul.nav { }
div.error { }
input.btn { }
span.badge { }
```

### Impacto
- **Acoplamiento HTML/CSS**: Si cambias `<div>` a `<section>`, rompes los estilos.
- **Specificity innecesaria**: El selector de tipo añade peso sin beneficio.
- **Reusabilidad limitada**: `.btn` no puede usarse en `<button>` o `<a>`.
- **Performance**: El navegador evalúa el tipo antes de la clase.

---

## Causa Raíz
- Miedo a que las clases "colisionen".
- Hábito de ser "explícito".
- No entender que las clases ya son únicas por contexto (BEM).

---

## Fix

```css
/* ✅ CORRECTO: clase pura */
.nav { }
.error { }
.btn { }
.badge { }
```

```html
<!-- HTML puede cambiar de elemento sin romper CSS -->
<nav class="nav">...</nav>
<div class="error">...</div>
<button class="btn">Go</button>
<a class="btn" href="/">Link</a>
<span class="badge">3</span>
```

---

## Excepciones

### 1. Reset / Normalize
```css
/* ✅ PERMITIDO */
body { margin: 0; }
img { max-width: 100%; }
```

### 2. Elementos sin clase (base styles)
```css
/* ✅ PERMITIDO en capa Elements de ITCSS */
h1, h2, h3 { font-weight: 700; }
a { color: var(--color-primary); }
```

### 3. Helper classes con combinador descendiente
```css
/* ✅ PERMITIDO: contexto semántico */
[role="list"] li { }
table td { }
```

---

## Regla
> **Nunca califiques una clase con un tipo de elemento.** La clase ya es suficiente.
