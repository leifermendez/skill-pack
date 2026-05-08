# Anti-Pattern: ID Selectors para Estilos

> Usar `#id` como selectores CSS en lugar de clases.

## El Problema

```css
/* ❌ PROHIBIDO */
#header { }
#main-nav { }
#sidebar { }
#footer { }
```

### Impacto
- **Specificity 100x mayor que una clase**: Un solo ID vence a 100 clases combinadas.
- **No reusable**: Un ID debe ser único por página.
- **Difícil de sobreescribir**: Necesitas otro ID o `!important`.
- **Problemas en equipo**: IDs globales generan colisiones.
- **JS vs CSS conflict**: El navegador expone IDs como propiedades globales (`window.header`).

---

## Causa Raíz
- Costumbre de HTML antiguo (pre-CSS3).
- Pensar que IDs son "más rápidos" (benchmarks modernos muestran diferencia negligible).
- CMS que genera IDs automáticamente.
- Copy-paste de ejemplos antiguos.

---

## Fix

### 1. Reemplazar por clases
```css
/* ✅ CORRECTO */
.header { }
.main-nav { }
.sidebar { }
.footer { }
```

```html
<header class="header">
  <nav class="main-nav"></nav>
</header>
```

### 2. Cuándo SÍ usar IDs
- **Anclas internas** (`<section id="features">`)
- **Form inputs** (para `label[for]` y accesibilidad)
- **Testing/QA hooks** (aunque mejor `data-test-id`)
- **JS hooks** (aunque mejor `data-js`)

> **Nunca** estilices por ID. Usa clases para todo el CSS visual.

---

## Google Style Guide sobre IDs

```css
/* Not recommended */
#example { }

/* Recommended */
.example { }
```

> Class selectors should be preferred in all situations.

---

## Regla
> **0 IDs en tu CSS.** Si encuentras uno, conviértelo a clase.
