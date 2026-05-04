# Card Organism Pattern

## Tarjetas Seamless (Vercel-Style)

Aplica la directriz de reducción de ruido visual en paneles y tarjetas.

## Principios Seamless para Cards

### Sombras Suaves
- Reducir la dependencia de `shadow-md` o sombras pesadas.
- Promover el uso exclusivo de `shadow-sm` con bordes muy sutiles (`border-gray-200/40` o `border-transparent`).
- **Hover effects:** Los bordes o sombras pueden acentuarse ligeramente al hacer `hover`:
  - `hover:border-gray-300 hover:shadow-md transition-all`
  - Manteniendo el reposo "Seamless".

### Integración de Skeletons
Los skeletons deben ser "Seamless". Usa colores difusos que se integren de forma natural con el fondo:
- `bg-gray-200/50` o `dark:bg-githubDark-surface/50`
- Sin verse como bloques toscos y opacos de alto contraste.

## Estructura de Card

### Card Compacta (Contenido Variable)

```tsx
// ✅ Card sin min-height forzado
<Card class="!min-h-0">
  <div class="flex flex-col gap-4 p-4">
    <div class="flex items-center gap-3">
      <Avatar src={user.avatar} alt={user.name} />
      <div>
        <h3 class="font-medium text-gray-900">{user.name}</h3>
        <p class="text-sm text-gray-500">{user.role}</p>
      </div>
    </div>
    <p class="text-sm text-gray-600">{user.bio}</p>
  </div>
</Card>
```

### Card en Grid

```tsx
// ✅ Grid con items-start para evitar estiramiento
<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 items-start">
  {items.map(item => (
    <Card key={item.id} class="!min-h-0">
      <div class="flex flex-col gap-4 p-4">
        <h3 class="font-semibold">{item.title}</h3>
        <p class="text-sm text-gray-600">{item.description}</p>
        <div class="flex gap-2">
          <Badge variant="info">{item.category}</Badge>
        </div>
      </div>
    </Card>
  ))}
</div>
```

### Card con Acción

```tsx
<Card>
  <div class="flex flex-col gap-4 p-6">
    <div class="flex items-start justify-between">
      <div>
        <h3 class="text-lg font-semibold">Proyecto Alpha</h3>
        <p class="text-sm text-gray-500">Última actualización: hace 2 días</p>
      </div>
      <Badge variant="success">Activo</Badge>
    </div>
    
    <p class="text-gray-600">
      Descripción breve del proyecto y sus objetivos principales...
    </p>
    
    <div class="flex justify-end gap-2 pt-2">
      <Button size="small" classBtn="text-gray-700">
        Ver detalles
      </Button>
      <Button size="small" classBtn="!bg-blue-600 !text-white">
        Editar
      </Button>
    </div>
  </div>
</Card>
```

## Ley de Espaciado en Tarjetas

> Esta ley aplica cuando se auditen **Cards, tarjetas o organismos** que usan átomos con `min-h-*` o contenedores con altura mínima.

### El Problema
Un átomo como `Card` puede tener `min-h-52` (208px) por defecto. Si el contenido real (título, metadata, footer) ocupa ~100px, queda **espacio vacío** entre el contenido y el borde inferior de la tarjeta — "espaciado mal aprovechado".

### Causas Típicas
1. **`min-h-*` en el átomo** — fuerza altura mínima aunque el contenido sea compacto.
2. **`flex-1` en el header** — hace crecer el bloque para llenar espacio sobrante.
3. **`h-full` en el contenedor interno** — estira el div al 100% del padre, ampliando el área vacía.
4. **Grid sin `items-start`** — las tarjetas se estiran para igualar la fila.

### Solución (Checklist)
- [ ] Si el organismo debe ajustarse al contenido: pasar `!min-h-0` al átomo Card para sobrescribir su `min-h-*`.
- [ ] Eliminar `flex-1` del header/bloque de contenido — no debe crecer.
- [ ] Eliminar `h-full` del contenedor interno cuando el padre tiene altura mínima — dejar que el contenido defina la altura.
- [ ] En grids de tarjetas: añadir `items-start` para alinear al tope y evitar que las tarjetas se estiren.
- [ ] Usar `gap-*` en el flex padre en lugar de `mt-*` en hijos para ritmo espacial predecible.

### Ejemplo Refactorizado

```tsx
// ✅ CardProject: override min-height del átomo
<Card class={['!min-h-0', ...]}>

// Contenedor interno: sin h-full
<div class="flex w-full flex-col gap-4 p-4">

// Grid padre: items-start
<div class="grid items-start gap-2.5 grid-cols-...">
```

## Checklist de Card Seamless

- [ ] Usa `shadow-sm` en lugar de `shadow-md`
- [ ] Bordes sutiles: `border-gray-200/40` o `border-transparent`
- [ ] Hover con transición sutil: `hover:border-gray-300 hover:shadow-md transition-all`
- [ ] Sin `min-h-*` forzado si el contenido es compacto: usar `!min-h-0`
- [ ] Sin `flex-1` ni `h-full` que generen espaciado vacío
- [ ] En grids: usar `items-start` para evitar stretch
- [ ] Skeleton usa colores difusos: `bg-gray-200/50`
