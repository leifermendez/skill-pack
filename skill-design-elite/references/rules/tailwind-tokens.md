# Tailwind Tokens Canónicos

## Paleta de Colores

### Grays (Neutros)
El Design System solo incluye: `50`, `100`, `200`, `400`, `600`, `800`, `900`

**No existen:** `gray-300`, `gray-500`, `gray-700` en el DS.

| Token | Uso |
|-------|-----|
| `gray-50` | Fondos muy sutiles |
| `gray-100` | Hover states, backgrounds secundarios |
| `gray-200` | **Bordes principales (light)** |
| `gray-400` | Texto disabled, iconos secundarios |
| `gray-600` | Texto secundario |
| `gray-800` | Texto principal |
| `gray-900` | Texto headings |

### Tokens Dark Mode (githubDark-*)

| Token | Uso |
|-------|-----|
| `githubDark-bg` | Fondo principal dark (`#0d1117`) |
| `githubDark-surface` | Superficies elevadas (`#161b22`) |
| `githubDark-border` | **Bordes principales (dark)** |
| `githubDark-text` | Texto principal |
| `githubDark-textSecondary` | Texto secundario |
| `githubDark-textTertiary` | Texto terciario |

### Colores de Marca

| Marca | Token | Uso |
|-------|-------|-----|
| WhatsApp | `whatsapp-green` | `focus:ring-whatsapp-green`, `bg-whatsapp-green` |
| Shopify | `shopify-green` | `focus-within:border-shopify-green`, `ring-shopify-green/20` |
| Telegram | `telegram-blue` | `focus:border-telegram-blue`, `bg-telegram-blue` |

## Bordes y Rings

### Tokens Canónicos

| Modo | Bordes | Rings |
|------|--------|-------|
| **Light** | `border-gray-200` | `ring-gray-200` (o `ring-gray-200/50` para sutiles) |
| **Dark** | `dark:border-githubDark-border` | `dark:ring-githubDark-border` |

### Patrón Prohibido

```tsx
// ❌ Incorrecto — gray-100, gray-300, gray-600/700/800 no son del DS
border-gray-100
border-gray-300
dark:border-gray-600
dark:border-gray-700
dark:ring-gray-700
```

### Patrón Correcto

```tsx
// ✅ Correcto — usa tokens del Design System
border-gray-200
dark:border-githubDark-border
ring-gray-200
dark:ring-githubDark-border
```

### Hover en Bordes

- `hover:border-gray-300` → reemplazar por `hover:border-gray-400` (sí existe en DS)
- `dark:hover:border-gray-500` → mantener en inputs si es necesario

### Constantes en design-system.ts

```ts
BORDERS.LIGHT   // 'border-gray-200'
BORDERS.DARK    // 'dark:border-githubDark-border'
BORDERS.LIGHT_SUBTLE  // 'border-gray-200/60'
```

## Espaciado (Gap)

### Escala DS de Espaciado

| Token | Valor | Uso típico |
|-------|-------|-----------|
| `gap-1` | 4px | Mínimo |
| `gap-2` | 8px | Pequeño |
| `gap-3` | 12px | Medio |
| `gap-4` | 16px | Estándar — grids de tarjetas, columnas de layout |
| `gap-6` | 24px | Secciones mayores |
| `gap-8` | 32px | Grandes separaciones |

**Prohibido:** `gap-2.5`, `gap-3.5`, `gap-5`, `gap-7` y cualquier valor que no esté en la tabla.

## Altura (Controles)

| Tamaño | Clase | Altura | Uso |
|--------|-------|--------|-----|
| Normal | `h-9` | 36px | Inputs, dropdowns, search |
| Compacto | `h-8` | 32px | Secondary actions inline |
| Grande | `h-10` | 40px | Hero inputs, primary CTA inline |

**Regla crítica:** `py-*` + `h-*` no conviven. El `py-*` es redundante cuando hay `h-*`.

```tsx
// ❌ Incorrecto — py-2 es redundante
<input class="h-9 py-2 ..." />

// ✅ Correcto — h-9 fija la altura
<input class="h-9 ..." />
```

## Border Radius

| Token | Valor | Uso |
|-------|-------|-----|
| `rounded-sm` | 2px | Bordes muy sutiles |
| `rounded` | 4px | Botones, tags |
| `rounded-md` | 6px | Cards pequeñas |
| `rounded-lg` | 8px | Cards, modales |
| `rounded-xl` | 12px | Cards prominentes |
| `rounded-2xl` | 16px | Modales grandes |
| `rounded-full` | 9999px | Avatares, badges |

## Sombras

| Token | Uso |
|-------|-----|
| `shadow-sm` | **Default** — cards, botones, elementos elevados sutiles |
| `shadow-md` | Hover states, dropdowns |
| `shadow-lg` | Modales, drawers (limitado) |
| `shadow-none` | Estados disabled, flat |

**Filosofía Seamless:** Preferir `shadow-sm` con bordes sutiles sobre sombras pesadas.

## Tipografía

### Escala de Tamaños

| Token | Tamaño | Uso |
|-------|--------|-----|
| `text-xs` | 12px | Metadata, labels, celdas de tabla |
| `text-sm` | 14px | Body text, descripciones |
| `text-base` | 16px | Texto principal (raramente usado en SaaS dense) |
| `text-lg` | 18px | Subtítulos |
| `text-xl` | 20px | Títulos de sección |
| `text-2xl` | 24px | Títulos de página (único por página) |

### Pesos

| Token | Uso |
|-------|-----|
| `font-normal` | Body text, subitems |
| `font-medium` | Labels, items activos, headers de categoría |
| `font-semibold` | Títulos, datos importantes |
| `font-bold` | Emphasis limitado |

### Tracking

| Token | Uso |
|-------|-----|
| `tracking-tight` | Headings grandes |
| `tracking-normal` | Body text default |
| `tracking-wider` | Labels uppercase |

## Z-Index

| Token | Uso |
|-------|-----|
| `z-10` | Elevaciones sutiles |
| `z-20` | Dropdowns, tooltips |
| `z-30` | Sticky headers |
| `z-40` | Modales backdrop |
| `z-50` | Modales content, toasts |

**Prohibido:** `z-[9999]`, `z-[100]` y valores arbitrarios. Usar la escala estándar.
