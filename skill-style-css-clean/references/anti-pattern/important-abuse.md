# Anti-Pattern: !important Abuse

> Uso excesivo de `!important` que rompe la cascada natural de CSS.

## El Problema

```css
/* ❌ PROHIBIDO */
.button {
  color: white !important;
}

.card {
  margin: 0 !important;
}
```

### Impacto
- La cascada deja de funcionar. Cada override requiere otro `!important`.
- Escala exponencialmente: `!important` genera más `!important`.
- Imposible de sobreescribir desde componentes hijos o temas.
- Señal de que perdiste el control de la specificity.

---

## Causa Raíz
- Specificity wars: usaste selectores largos y ahora necesitas forzar.
- Estilos inline de librerías de terceros.
- Copy-paste de Stack Overflow sin entender.
- Desesperación por deadline.

---

## Fix

### 1. Aumentar specificity legítimamente
```css
/* ✅ CORRECTO */
.btn.btn--primary {
  color: white;
}
```

### 2. Reestructurar el HTML
```html
<!-- ❌ Antes: specificity wars -->
<div class="page">
  <div class="content">
    <button class="btn">Go</button>
  </div>
</div>

<!-- ✅ Después: classes planas -->
<button class="btn btn--primary">Go</button>
```

### 3. Única excepción: Utilities ITCSS
```css
/* ✅ PERMITIDO (y solo aquí) */
.u-hidden { display: none !important; }
.u-text-center { text-align: center !important; }
```

---

## Detección

Busca en tu codebase:
```bash
grep -r "!important" --include="*.css" --include="*.scss" .
```

Si hay más de 5 en un proyecto mediano, tienes un problema.
