# Height Consistency Rules

## 📏 Ley de Consistencia de Altura — Token `h-9` (LEER SIEMPRE)

> Esta ley aplica en **cualquier fase** cuando se auditen o creen elementos interactivos que coexistan en la misma fila horizontal (filtros, toolbars, search bars, form inline rows).

**Regla absoluta:** Todo control interactivo que se renderice en la misma fila que otros controles DEBE usar un token de altura explícito (`h-*`). **Prohibido usar `py-*` como sustituto de altura.**

## Por Qué Importa

`py-2` produce alturas diferentes según el `font-size` del elemento, el `line-height` del texto y el grosor del `border`. Dos controles con `py-2` pueden tener alturas distintas si difieren en `text-sm` vs `text-xs`. El resultado visual son rows desalineados que rompen el ritmo espacial del layout.

## Token Estándar del Proyecto

| Tamaño | Clase | Altura |
|--------|-------|--------|
| Normal (inputs, dropdowns, search) | `h-9` | 36px |
| Compacto (secondary actions inline) | `h-8` | 32px |
| Grande (hero inputs, primary CTA inline) | `h-10` | 40px |

**Ancho de botones:** El átomo `<Button>` size normal usa `min-w-8 px-3` (compacto). No usar `min-w-9 px-4` — los botones deben ser ligeramente menos anchos.

## Regla Crítica: `py-*` + `h-*` No Conviven

```tsx
// ❌ Incorrecto — py-2 es redundante y puede causar overflow en height fija
<input class="h-9 py-2 ..." />

// ✅ Correcto — h-9 fija la altura, no se necesita py-*
<input class="h-9 ..." />
```

## Checklist de Altura en Rows Inline

- [ ] Todos los controles de la fila usan el **mismo token `h-*`**
- [ ] Ningún control usa solo `py-*` sin `h-*` en contexto inline
- [ ] Si un control tiene `h-*` Y `py-*`, el `py-*` se elimina (redundante)
- [ ] Los iconos dentro de controles usan `h-4 w-4` o `h-3.5 w-3.5` (no `text-sm` para tamaño)

## Casos que Siempre Deben Reportarse

### `[ALTO]` — Altura Inconsistente
- Control en toolbar/filterbar con solo `py-*` y sin `h-*`
- Control con `h-*` **y** `py-*` simultáneamente (`py-*` es redundante)
- Dos controles en la misma fila con tokens de altura distintos (`h-9` vs `h-10`)

### `[MEDIO]` — Optimización
- Control con altura implícita que podría ser explícita
- Padding vertical excesivo que podría simplificarse

## Ejemplos

### ❌ Incorrecto
```tsx
// Anti-patrón — py-2 produce altura dependiente del line-height. En row inline desalinea.
<input class="py-2 pl-3 pr-3 ..." />
<button class="py-2 px-4 ...">Filtrar</button>
```

### ✅ Correcto
```tsx
// Altura explícita consistente en toda la fila
<div class="flex items-center gap-2">
  <input class="h-9 pl-3 pr-3 ..." />
  <button class="h-9 min-w-8 px-3 ...">Filtrar</button>
  <select class="h-9 pl-3 pr-8 ...">
    <option>...</option>
  </select>
</div>
```

### Fila Compacta
```tsx
// Para acciones secundarias inline
<div class="flex items-center gap-2">
  <button class="h-8 px-2 ...">Editar</button>
  <button class="h-8 px-2 ...">Eliminar</button>
</div>
```

## Integración con Otros Controles

### SelectOptions
```tsx
// ✅ Altura consistente con inputs
<SelectOptions class="h-9 ..." />
```

### ToolbarButton
```tsx
// ✅ ToolbarButton ya incluye h-9 por defecto
<ToolbarButton>
  <LuFilter class="h-4 w-4" />
</ToolbarButton>
```

### Input con prefixIcon
```tsx
// ✅ Input maneja altura internamente
<Input 
  prefixIcon="search" 
  class="h-9" 
  placeholder="Buscar..."
/>
```
