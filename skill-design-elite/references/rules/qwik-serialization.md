# Qwik Serialization Rules

## Alerta QWIK — Regla de Serialización en `$()` (LEER SIEMPRE)

> Esta regla aplica en **cualquier fase** cuando se escriben o refactorizan event handlers.

Qwik serializa el scope capturado por cada `$()` closure. **Si el closure captura un objeto que contiene funciones** (componentes de iconos, handlers no-QRL, instancias de clase), el runtime lanzará:
```
Value cannot be serialized in _.icon, because it's a function named "LuXxx"
```

## Regla Rápida

En handlers de accesibilidad (`onKeyDown$`, `onFocus$`, etc.) que solo necesitan disparar el click del elemento, usar siempre el patrón sin captura de scope:

```tsx
// ✅ Correcto — no captura nada del scope externo
onKeyDown$={$((e) => {
  if (e.key === 'Enter' || e.key === ' ') (e.target as HTMLElement).click();
})}

// ❌ Incorrecto — captura `item` que puede contener funciones (.icon, .component...)
onKeyDown$={$((e) => {
  if (e.key === 'Enter' && 'action' in item) item.action();
})}
```

## El Problema

Qwik serializa el estado de la aplicación para hidratación. Cuando creas un closure con `$()`, **todas las variables capturadas del scope exterior deben ser serializables**. Las funciones de componente (iconos como `LuBot`, `LuLayoutDashboard`, handlers inline, etc.) **no son serializables** y lanzan error en runtime.

## Regla de Oro

**Un `$()` closure NO debe capturar objetos que contengan funciones.**

### Patrón Incorrecto — Captura `item` (que tiene `.icon` función)

```tsx
// ❌ item.icon = LuBot (función) → Qwik no puede serializar item
<div onKeyDown$={$((e) => {
  if ((e.key === 'Enter' || e.key === ' ') && 'action' in item) {
    item.action();
  }
})} />
```

### Patrón Correcto — No Captura Nada del Scope Externo

```tsx
// ✅ Solo usa `e` del evento — nada del scope externo
<div onKeyDown$={$((e) => {
  if (e.key === 'Enter' || e.key === ' ') (e.target as HTMLElement).click();
})} />
```

> El `.click()` sintético dispara el `onClick$` ya existente en el mismo elemento, sin necesidad de referenciar `item`.

## Checklist Antes de Escribir un `$()` Closure

- [ ] ¿El closure referencia alguna variable del scope externo?
- [ ] Si sí, ¿esa variable contiene funciones, clases, o referencias DOM?
- [ ] Si la respuesta es "sí" → reescribir para eliminar la captura o delegar al `onClick$` vía `.click()`.

## Variables que NUNCA Deben Capturarse en `$()`

| Tipo | Ejemplo | Razón |
|------|---------|-------|
| Objetos con propiedades función | `item.icon`, `item.action` (si no es QRL) | Las funciones no son JSON-serializable |
| Componentes Qwik/React | `LuBot`, `Avatar`, `Button` | Son funciones |
| Instancias de clase | `new MyClass()` | Prototipos no serializables |
| Refs DOM directas | `element`, `ref.value` | Viven solo en el cliente |

## Variables que SÍ Pueden Capturarse en `$()`

| Tipo | Ejemplo |
|------|---------|
| Strings, numbers, booleans | `item.label`, `item.path`, `isOpen` |
| QRLs (creados con `$()`) | `item.action` cuando es `$(() => navigate(...))` |
| Signals de Qwik | `signal.value` |
| Arrays/objetos de datos puros | `{ id: '1', name: 'foo' }` |

## Regla Crítica Adicional — Props Serializables Entre `component$`

Aunque no haya closure `$()` explícito, Qwik también serializa props al pausar SSR.  
Si pasas un componente/función por props (ej. `prefixIcon={<LuSearch />}` o `icon={LuSearch}`), puede romper con:

```
Code(3): Only primitive and object literals can be serialized [Function: LuSearch]
```

### Prohibido

```tsx
// ❌ Pasa JSX/función por props => no serializable
<Input prefixIcon={<LuSearch class="h-4 w-4" />} />
<MenuItem icon={LuSearch} />
```

### Obligatorio

```tsx
// ✅ Pasar identificador serializable (string/enum)
<Input prefixIcon="search" />
```

```tsx
// Dentro del átomo/componente receptor
{props.prefixIcon === 'search' && <LuSearch class="h-4 w-4" />}
```

### Checklist Rápido (Props)

- [ ] ¿La prop contiene JSX, función o componente? -> reemplazar por token serializable (`string`, `number`, `boolean`, objeto literal puro).
- [ ] ¿El componente receptor puede mapear ese token a UI interna? -> implementar mapping dentro del átomo.
- [ ] ¿Evita pasar clases/comportamiento no serializable por props? -> mantener API de props data-first.

## Regla Adicional Crítica — i18n `t(...)` en Qwik

En este proyecto, `useLanguage().t` viene con `noSerialize(...)`.  
Por lo tanto, **evita usar `t(...)` inline** en JSX o dentro de closures `$()` en componentes que tengan QRLs, ya que puede romper en runtime:

```
TypeError: p0.t is not a function
```

### Prohibido

```tsx
// ❌ Inline en JSX
<div aria-label={t('menu.deploy_status_aria_label')} />

// ❌ Dentro de closure $()
const onFail$ = $(() => notify(t('menu.error_generic')));
```

### Obligatorio

```tsx
// ✅ Resolver traducciones una sola vez (fuera de $)
const deployStatusAriaLabel = t('menu.deploy_status_aria_label');
const errorGeneric = t('menu.error_generic');

<div aria-label={deployStatusAriaLabel} />
const onFail$ = $(() => notify(errorGeneric));
```

### En Componentes Hijos

- Pasar traducciones como `string` prop desde el padre:
  - `childLabel={settingsAriaLabel}`
- Evitar `useLanguage()` en hijos con muchos QRLs si el texto ya puede venir del padre.
