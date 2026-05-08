# Anti-Pattern: Dead Code (Código Muerto)

> Reglas CSS que no se aplican a ningún elemento o están comentadas indefinidamente.

## El Problema

```css
/* ❌ PROHIBIDO */
.legacy-widget { display: none; }  /* Widget eliminado hace 6 meses */

/*.old-banner { ... }*/            /* Comentado desde v1.0 */

.sidebar {                         /* Sidebar fue reemplazado por drawer */
  width: 250px;
  float: left;
}

@media print {
  .no-print { display: none; }    /* No hay elementos con clase .no-print */
}
```

### Impacto
- **Tamaño de bundle**: Cada byte cuenta en mobile.
- **Confusión**: Desarrolladores nuevos no saben qué está activo.
- **Riesgo de regresión**: Reactivar código muerto puede romper layouts.
- **Mantenimiento costoso**: Más código = más tiempo de lectura.

---

## Causa Raíz
- Miedo a borrar "por si acaso".
- No hay proceso de code review enfocado en CSS.
- Falta de herramientas de análisis (coverage).
- Cambios rápidos sin limpieza posterior.

---

## Fix

### 1. PurgeCSS / UnCSS
```bash
# Instala y corre en build time
npx purgecss --css style.css --content src/**/*.html --output style.min.css
```

### 2. Chrome DevTools Coverage
> DevTools → More Tools → Coverage. Carga la página y mira qué CSS no se ejecutó.

### 3. Regla de oro
```css
/* ❌ NUNCA dejes código comentado */
/*.old-class { ... }*/

/* ✅ Bórralo. Git lo recuerda si lo necesitas. */
```

### 4. CSS Stats
```bash
npx cssstats style.css
```
> Te dice: total rules, selectors, declarations, y identifica duplicados.

---

## Regla
> **Si una clase no aparece en el HTML, no debe existir en el CSS.** Usa herramientas para verificar, no confíes en tu memoria.
