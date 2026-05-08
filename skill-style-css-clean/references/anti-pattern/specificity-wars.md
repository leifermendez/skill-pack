# Anti-Pattern: Specificity Wars

> Selectores excesivamente largos y específicos que dificultan la reusabilidad y el mantenimiento.

## El Problema

```css
/* ❌ PROHIBIDO */
.page .sidebar .widget .title { }
#content .post .entry a { }
header nav ul li a span { }
```

### Impacto
- **Rendimiento**: El navegador debe evaluar más selectores de derecha a izquierda.
- **Fragilidad**: Un cambio en el HTML rompe los estilos.
- **Especificidad infinita**: No puedes sobreescribir sin `!important`.
- **Duplicación**: Necesitas replicar la cadena para aplicar los mismos estilos en otro lugar.

---

## Causa Raíz
- Depender de la estructura HTML para estilizar.
- No usar una metodología de naming (BEM, SMACSS).
- Miedo a que los estilos "se pierdan" en la cascada.

---

## Fix

```css
/* ✅ CORRECTO */
.widget__title { }
.entry__link { }
.nav__link-text { }
```

### Regla de oro
> Si necesitas más de 3 clases/elementos en un selector, estás haciendo algo mal.

---

## Casos Especiales

### Override forzado
```css
/* ❌ PROHIBIDO: sobrescribir con specificity alta */
#header .nav .item.active a { color: red; }

/* ✅ CORRECTO: usar BEM y specificity plana */
.nav__link--active { color: red; }
```

### Frameworks CSS-in-JS
```css
/* ❌ PROHIBIDO: CSS Modules sin cuidado */
.Button_button__3xK9l .Button_icon__2aBc { }

/* ✅ CORRECTO: hashes solo en el block */
.Button__3xK9l { }
.Button__icon__2aBc { }
```
