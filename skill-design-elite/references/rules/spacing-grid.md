# Spacing and Grid Rules

## 📐 Ley de Oro — Consistencia de Grid y Espaciado (LEER SIEMPRE)

> Esta ley aplica en **cualquier fase** cuando se auditen o creen grids, layouts flex con gap, skeletons o contenedores de página.

### La Regla de Oro

> **Todo grid o layout flex con gap debe usar exclusivamente tokens de la escala DS. El skeleton correspondiente debe usar exactamente el mismo token de gap que el contenido real. El contenedor de página usa `p-4` para aire lateral uniforme con el Header.**

## Escala DS de Espaciado (únicos valores permitidos en `gap-*`, `p-*`, `m-*`)

| Token | Valor | Uso típico |
|-------|-------|-----------|
| `gap-1` | 4px | Mínimo |
| `gap-2` | 8px | Pequeño |
| `gap-3` | 12px | Medio |
| `gap-4` | 16px | Estándar — grids de tarjetas, columnas de layout |
| `gap-6` | 24px | Secciones mayores |
| `gap-8` | 32px | Grandes separaciones |

**Prohibido:** `gap-2.5`, `gap-3.5`, `gap-5`, `gap-7` y cualquier valor que no esté en la tabla. Reportar como `[ALTO]`.

## Regla Skeleton = Espejo Exacto del Contenido Real

El skeleton de un organismo debe usar **exactamente el mismo** token `gap-*`, número de columnas, padding y estructura flex/grid que el contenido real que reemplaza. Si difieren, la transición skeleton → contenido produce un layout shift visible.

```tsx
// ❌ Layout shift — skeleton usa gap-4, contenido usa gap-2.5
<div class="flex gap-4">          {/* Skeleton */}
<div class="flex gap-2.5">        {/* Real */}

// ✅ Correcto — token idéntico en ambos
<div class="flex gap-4">          {/* Skeleton */}
<div class="flex gap-4">          {/* Real */}
```

## Regla del Contenedor de Página

El div wrapper del contenido debajo del Header siempre lleva `p-4`. El Header ya usa `px-4`; el contenido sin `p-4` queda sin aire lateral uniforme.

```tsx
// ❌ Sin padding — el contenido choca con los bordes
<div class="rounded-lg">

// ✅ Correcto — aire lateral uniforme con el Header
<div class="p-4">
```

## Grid de Tarjetas

```tsx
// ✅ Correcto — items-start evita que tarjetas se estiren
<div class="grid grid-cols-3 gap-4 items-start">
  <Card>...</Card>
  <Card>...</Card>
  <Card>...</Card>
</div>

// ❌ Incorrecto — sin items-start, tarjetas se estiran a la más alta
<div class="grid grid-cols-3 gap-4">
```

## Checklist de Grid Consistency

- [ ] Todos los `gap-*` usan tokens DS: `gap-1/2/3/4/6/8` — nunca `gap-2.5`, `gap-5`, etc.
- [ ] El skeleton de cada organismo usa el mismo `gap-*` que el contenido real (espejo exacto)
- [ ] El contenedor de página debajo del Header usa `p-4`
- [ ] Los grids de tarjetas tienen `items-start` para evitar stretch de tarjetas en filas desiguales
- [ ] Skeletons replican también el número de columnas (`grid-cols-*`) del contenido real

## Tokens de Padding

| Token | Valor | Uso |
|-------|-------|-----|
| `p-1` | 4px | Espaciado mínimo |
| `p-2` | 8px | Compacto |
| `p-3` | 12px | Medio |
| `p-4` | 16px | Estándar — contenedores de página |
| `p-5` | 20px | Cards internas |
| `p-6` | 24px | Cards principales |
| `p-8` | 32px | Secciones grandes |

## Responsive Grids

```tsx
// ✅ Grid responsive con breakpoints
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 items-start">
  ...
</div>

// ✅ Grid consistente en skeleton
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 items-start">
  <SkeletonCard />
  <SkeletonCard />
  <SkeletonCard />
</div>
```

## Ley de Espaciado Premium en Documentación

### Tokens de Espaciado (escala 8px)

| Contexto | Token | Valor |
|----------|-------|-------|
| Padding contenedor principal | `py-8 lg:py-12` | 32px / 48px |
| Separación entre secciones grandes | `py-12` | 48px |
| Separación entre endpoints/bloques | `py-8` | 32px |
| Headers de sección | `pt-10 pb-6` | 40px / 24px |
| Gaps en grids de dos columnas | `gap-x-10 gap-y-8` | 40px / 32px |
| Padding interno en cards/tablas | `p-5` | 20px |

**Principio:** Más aire entre secciones que dentro de bloques. El ritmo es predecible — todos los valores son múltiplos de 8px.
