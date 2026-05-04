# Input Atom Pattern

## `<Input>` — `~/atoms/input.tsx`

Usar en lugar de `<input>` nativo con clases manuales.

## Modos de Uso (Crítico — Elegir Uno)

| Modo | Props | Cuándo usar |
|------|-------|-------------|
| **Controlado** | `value={x}` + `onInput$={...}` | Estado en `useStore` o `useSignal` con lógica personalizada |
| **No controlado** | `bind:value={signal}` | Binding bidireccional directo a un `Signal<string>` |

**Regla crítica:** NO mezclar ambos modos (`value` + `bind:value` a la vez).

## Props Disponibles

| Prop | Tipo | Descripción |
|------|------|-------------|
| `value` | `string` | Modo controlado — valor actual |
| `bind:value` | `Signal<string>` | Modo no controlado — binding bidireccional |
| `prefixIcon` | `string` | Identificador serializable (ej. `"search"`, `"warning"`) |
| `placeholder` | `string` | Texto placeholder |
| `disabled` | `boolean` | Desactiva el input |
| `class` | `string` | Clases adicionales |

## Ley de `bind:value` Condicional (Crítico)

El átomo `Input` pasaba `bind:value={props['bind:value']}` **siempre**, aunque el caller no lo proporcionara. Cuando es `undefined`, Qwik intenta crear un binding hacia un target inexistente y al escribir lanza:

```
TypeError: Cannot set properties of undefined (setting 'value')
```

### Fix Aplicado

`bind:value` solo se pasa cuando está definido, usando spread condicional:

```tsx
// ✅ Correcto — omite el atributo cuando no se pasa
{...(props['bind:value'] != null && { 'bind:value': props['bind:value'] })}

// ❌ Incorrecto — se pasa siempre, aunque sea undefined
bind:value={props['bind:value']}
```

**Regla general para cualquier átomo que acepte `bind:value` como prop:** Siempre usar spread condicional. **Nunca** pasar `bind:value={props['bind:value']}` directamente sin comprobar que no sea `undefined`.

### Dos Modos Soportados

- `value` + `onInput$` → modo controlado (sin `bind:value`)
- `bind:value={signal}` → modo no controlado (binding bidireccional)

## Padding Horizontal (Corregido)

El átomo aplica `pl-3 pr-3` por defecto:
- Sin `prefixIcon`: padding simétrico
- Con `prefixIcon="search"`: padding izquierdo sube a `pl-10` para dar espacio al icono

## Altura

El átomo Input debe usarse con altura explícita:

```tsx
// ✅ Correcto
<Input class="h-9" placeholder="Buscar..." />

// ✅ En contexto inline con otros controles
<div class="flex items-center gap-2">
  <Input class="h-9" prefixIcon="search" placeholder="Buscar..." />
  <Button class="h-9">Buscar</Button>
</div>
```

## Iconos Serializables

### Prohibido — Pasar JSX
```tsx
// ❌ Pasa JSX/función por props => no serializable
<Input prefixIcon={<LuSearch class="h-4 w-4" />} />
```

### Correcto — Token Serializable
```tsx
// ✅ Pasar identificador serializable (string/enum)
<Input prefixIcon="search" />

// Dentro del átomo Input
{props.prefixIcon === 'search' && <LuSearch class="h-4 w-4" />}
{props.prefixIcon === 'warning' && <LuAlertCircle class="h-4 w-4" />}
```

## Ejemplos

### Modo Controlado
```tsx
const searchValue = useSignal('');

<Input 
  value={searchValue.value}
  onInput$={(e) => searchValue.value = e.target.value}
  class="h-9"
  placeholder="Buscar..."
/>
```

### Modo No Controlado (Binding)
```tsx
const searchSignal = useSignal('');

<Input 
  bind:value={searchSignal}
  class="h-9"
  placeholder="Buscar..."
/>
```

### Con Icono
```tsx
<Input 
  prefixIcon="search"
  class="h-9"
  placeholder="Buscar usuarios..."
/>
```

### En Form Inline
```tsx
<div class="flex items-center gap-2">
  <Input 
    bind:value={emailSignal}
    class="h-9"
    placeholder="email@ejemplo.com"
  />
  <Button class="h-9" loading={isSubmitting}>
    Suscribirse
  </Button>
</div>
```

## Anti-Patrón Prohibido

```tsx
// ❌ INCORRECTO — <input> nativo con clases manuales
<input 
  class="border border-gray-300 rounded px-3 py-2 focus:ring-2 ..."
  type="text"
  placeholder="Buscar..."
/>
```
