# Anti-Pattern: Universal Selector Overuse

> Abuso del selector universal `*` para aplicar propiedades globales costosas.

## El Problema

```css
/* ❌ PROHIBIDO */
* {
  margin: 0;
  padding: 0;
  transition: all 0.3s ease;
  box-shadow: none;
}
```

### Impacto
- **Rendimiento**: `*` selecciona TODOS los elementos (incluyendo pseudo-elements).
- **Transition en todo**: Cualquier cambio de propiedad anima. Fuerza repaint/relayout constante.
- **Efectos secundarios**: Librerías de terceros, icon fonts, iframes se ven afectados.
- **Specificity mínima pero alcance máximo**: Difícil de sobreescribir sin specificity alta.

---

## Causa Raíz
- Reset CSS copy-pasteado de hace 10 años.
- "Es más fácil quitar margin/padding de todo".
- No entender el costo de `transition: all`.

---

## Fix

### 1. Reset moderno y limitado
```css
/* ✅ CORRECTO: solo box-sizing */
*,
*::before,
*::after {
  box-sizing: border-box;
}
```

### 2. Reset de elementos específicos
```css
/* ✅ CORRECTO: Modern CSS Reset */
body, h1, h2, h3, h4, p, figure, blockquote, dl, dd {
  margin: 0;
}

ul[role='list'],
ol[role='list'] {
  list-style: none;
  padding: 0;
}
```

### 3. Transiciones solo donde se necesitan
```css
/* ❌ PROHIBIDO */
* { transition: all 0.3s ease; }

/* ✅ CORRECTO */
.btn {
  transition: background-color 0.2s ease,
              transform 0.2s ease;
}

.modal {
  transition: opacity 0.3s ease,
              transform 0.3s ease;
}
```

---

## Regla
> `*` solo para `box-sizing: border-box`. Todo lo demás va en elementos específicos. Nunca apliques `transition`, `animation`, `box-shadow`, o `transform` al `*`.
