# Button Atom Pattern

## `<Button>` — `~/atoms/button.tsx`

### Estructura DOM Renderizada

```html
<div class={className}>              <!-- wrapper externo de layout -->
  <div class="bg-white ring-1 ..."> <!-- tarjeta visual blanca -->
    <button class={classBtn}>       <!-- elemento interactivo real -->
```

### Props Clave

| Prop | Tipo | Descripción |
|------|------|-------------|
| `loading` | `boolean` | Muestra spinner `<ISpinner>` y oculta el slot. **Usar en lugar de cualquier `<LoadingSpinner>` manual dentro del botón.** |
| `disabled` | `boolean` | Desactiva y aplica `cursor-not-allowed opacity-50`. |
| `size` | `'normal' \| 'small' \| 'tiny'` | Controla el padding interno. |
| `class` | `string` | Clases para el div wrapper (layout externo). |
| `classBtn` | `string` | Clases para el `<button>` interno (color de texto/fondo). |

### Tokens de Ancho

**Size normal:** `h-9 min-w-8 px-3` — botones compactos, no excesivamente anchos.
- Icon-only: `min-w-8` (32px)
- Con texto: `px-3` (12px horizontal)

### Restricciones Conocidas

- No tiene prop `variant` — un único estilo visual (blanco + ring).
- El div-wrapper es incompatible con `role="tab"` (usar `<button>` nativo justificado con comentario).
- El div-wrapper es incompatible con grupos `inline-flex` de botones adyacentes → usar `flex gap-2`.

### Botones Primarios (CTA Sólido Reutilizable)

Para las llamadas a la acción principales (CTAs), usa una clase reusable centralizada y evita strings largos en `classBtn`:

```tsx
classBtn="btn-primary-cta"
```

## `<ToolbarButton>` — `~/atoms/toolbar-button.tsx`

### Uso

Usar en toolbars y headers para acciones secundarias/primarias en línea con otros controles.

### Estructura DOM Renderizada

Un único `<button>` (sin div-wrapper), con:
```
h-9 border border-gray-200 bg-white text-gray-800
```

### Props Clave

| Prop | Tipo | Descripción |
|------|------|-------------|
| `classBtn` | `string` | Clases adicionales fusionadas en el `<button>`. |
| `loading` | `boolean` | Muestra `<ISpinner>` y desactiva el botón. |
| `disabled` | `boolean` | Desactiva y aplica `opacity-50 cursor-not-allowed`. |
| `roundedS` / `roundedE` | `boolean` | Para agrupar botones (primer/último en un grupo). |

### Ley de Override en Átomos con `classBtn` (Crítica)

**Problema:** Tailwind genera todas las utilities en orden fijo alfabético dentro del CSS output. Pasar `text-white bg-blue-600` en `classBtn` puede **no funcionar** si el `BASE_CLS` del átomo ya incluye `text-gray-800 bg-white`.

**Regla:** Si necesitas sobreescribir un color del átomo con `classBtn`, usa el prefijo `!` (Tailwind important):

```tsx
// ❌ Incorrecto — el text-white puede ser vencido por text-gray-800 del BASE_CLS
<ToolbarButton classBtn="bg-blue-600 text-white">...</ToolbarButton>

// ✅ Correcto — ! garantiza que el override gana siempre
<ToolbarButton classBtn="!bg-blue-600 !text-white hover:!bg-blue-700">...</ToolbarButton>
```

**Regla de preferencia:** Antes de usar `!important`, evalúa si el botón simplemente debe usar el tema visual por defecto del átomo (blanco + borde gris).

### Cuándo Usar `ToolbarButton` vs `Button`

| Situación | Átomo correcto |
|-----------|----------------|
| Acción en toolbar / header junto a otros controles | `ToolbarButton` |
| Acción standalone (modal footer, card action) | `Button` |
| Acción con loading (submit, envío) | `Button` (tiene ring + shadow de feedback) |
| Icon-only circular (close button, delete compact) | Nativo justificado con comentario |

## Ejemplos

### Botón Estándar
```tsx
<Button onClick$={handleSave}>
  <LuSave class="h-4 w-4" />
  Guardar
</Button>
```

### Botón con Loading
```tsx
<Button loading={isSaving} onClick$={handleSave}>
  <LuSave class="h-4 w-4" />
  Guardar
</Button>
```

### Botón Pequeño con Color Personalizado
```tsx
<Button 
  size="small" 
  onClick$={handleDelete} 
  classBtn="text-red-600 dark:text-red-400"
>
  <LuTrash class="h-3.5 w-3.5" />
  Eliminar
</Button>
```

### ToolbarButton en Fila de Controles
```tsx
<div class="flex items-center gap-2">
  <Input class="h-9" placeholder="Buscar..." />
  <ToolbarButton classBtn="!bg-blue-600 !text-white">
    <LuFilter class="h-4 w-4" />
    Filtrar
  </ToolbarButton>
</div>
```

## Anti-Patrón Prohibido

```tsx
// ❌ INCORRECTO — <button> nativo con clases Tailwind manuales
<button class="bg-blue-600 text-white px-4 py-2 rounded ...">
  Guardar
</button>
```
