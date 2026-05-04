# Border Consistency Rules

## Ley de Consistencia de Bordes y Colores (LEER SIEMPRE)

> Esta ley aplica en **cualquier fase** cuando se auditen o creen bordes, rings o separadores visuales.

**Referencia:** Paleta gray del Design System solo incluye 50, 100, 200, 400, 600, 800, 900. No existen `gray-300`, `gray-500`, `gray-700` en el DS.

## Tokens Canónicos

| Modo | Bordes | Rings |
|------|--------|-------|
| **Light** | `border-gray-200` | `ring-gray-200` (o `ring-gray-200/50` para sutiles) |
| **Dark** | `dark:border-githubDark-border` | `dark:ring-githubDark-border` |

## Patrón Prohibido

```tsx
// ❌ Incorrecto — gray-100, gray-300, gray-600/700/800 no son del DS
border-gray-100
border-gray-300
dark:border-gray-600
dark:border-gray-700
dark:ring-gray-700
```

## Patrón Correcto

```tsx
// ✅ Correcto — usa tokens del Design System
border-gray-200
dark:border-githubDark-border
ring-gray-200
dark:ring-githubDark-border
```

## Hover en Bordes

- `hover:border-gray-300` → reemplazar por `hover:border-gray-400` (sí existe en DS: "Text disabled / Secondary icons")
- `dark:hover:border-gray-500` → mantener en inputs si es necesario

## Tokens de Marca (Evitar Arbitrarios)

Colores de integración ya definidos en `tailwind.config.js`:

| Marca | Token | Uso |
|-------|-------|-----|
| WhatsApp | `whatsapp-green` | `focus:ring-whatsapp-green`, `bg-whatsapp-green` |
| Shopify | `shopify-green` | `focus-within:border-shopify-green`, `ring-shopify-green/20` |
| Telegram | `telegram-blue` | `focus:border-telegram-blue`, `bg-telegram-blue` |

## Constantes en design-system.ts

```ts
BORDERS.LIGHT   // 'border-gray-200'
BORDERS.DARK    // 'dark:border-githubDark-border'
BORDERS.LIGHT_SUBTLE  // 'border-gray-200/60'
```

## Ley de Separadores en Sidebar/Navegación (Minimalismo)

> Esta ley aplica cuando se auditen o creen **Sidebars, menús de navegación lateral o listas de secciones** que requieran jerarquía visual sin romper el minimalismo.

**Objetivo:** Añadir separadores sutiles que organicen el contenido en bloques lógicos sin saturar visualmente.

**Tokens canónicos para separadores sutiles:**

| Uso | Light | Dark |
|-----|-------|------|
| Separador entre secciones | `border-gray-200/60` | `dark:border-githubDark-border/60` |
| Separador antes de CTA/área destacada | `border-t border-gray-200/60` | `dark:border-t dark:border-githubDark-border/60` |

**Patrón aplicado:**
- **Entre secciones de nav:** `border-b` en cada sección excepto la última (`idx < items.length - 1`).
- **Antes de notificaciones/alertas:** `border-t pt-2` para separar nav del bloque de notificaciones.
- **Antes de CTA (ej. botón Premium):** `border-t pt-2 mt-2` para separar el área de upgrade del scroll principal.
- **Skeleton:** Replicar la misma estructura de separadores para que el loading state coincida con el diseño final.

**Ejemplo — secciones con separadores:**
```tsx
{navItems.map((section, idx) => (
  <div
    key={section.section}
    class={[
      'px-0 py-2',
      idx < navItems.length - 1 && 'border-b border-gray-200/60 dark:border-githubDark-border/60',
    ]}
  >
    {/* contenido de sección */}
  </div>
))}
```

**Ejemplo — separador antes de CTA:**
```tsx
<div class="mt-2 border-t border-gray-200/60 pt-2 dark:border-githubDark-border/60">
  <PremiumButton />
</div>
```

**Regla:** Usar `gap-0` en el contenedor padre cuando se añaden separadores explícitos; el `border-*` y `py-*`/`pt-*` definen el ritmo espacial.

## Ley Anti-Doble-Border (Bordes que Colapsan)

> Esta ley aplica cuando se auditen **modales, paneles o layouts** con header + subsecciones consecutivas.

**Problema:** Dos elementos hermanos con `border-b` (o dos con `border-t`) adyacentes crean una línea de 2px que rompe el minimalismo y genera mala imagen visual.

**Patrón prohibido:**
```tsx
// ❌ Doble línea — Header y StepIndicator tienen border-b adyacentes
<div class="border-b border-gray-200">Header</div>
<div class="border-b border-gray-200">Step Indicator</div>
```

**Solución:** Un solo `border-b` (o `border-t`) entre bloques lógicos. Agrupar header + subheader en un bloque sin border interno, y poner el único `border-b` en el último elemento antes del contenido.
```tsx
// ✅ Una sola línea — Header sin border, StepIndicator tiene el único border-b
<div class="px-4 py-3">Header</div>
<div class="border-b border-gray-200 dark:border-githubDark-border">Step Indicator</div>
<div class="px-4 py-4">Content</div>
```

**Checklist anti-doble-border:**
- [ ] No hay dos `border-b` consecutivos sin contenido entre ellos
- [ ] No hay dos `border-t` consecutivos sin contenido entre ellos
- [ ] En modales: header, step-indicator y content comparten como máximo un `border-b` entre ellos

## Checklist de Bordes

- [ ] Bordes neutros usan `border-gray-200` (light) y `dark:border-githubDark-border` (dark)
- [ ] Rings neutros usan `ring-gray-200` (light) y `dark:ring-githubDark-border` (dark)
- [ ] No hay `border-[#...]` ni `ring-[#...]` — usar tokens de marca
- [ ] `dark:bg-[#0d1117]` → `bg-githubDark-bg`; `dark:bg-[#161b22]` → `bg-githubDark-surface`
