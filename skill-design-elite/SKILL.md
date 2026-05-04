---
name: skill-design-elite
description: Enterprise UI/UX auditor for SaaS. Enforces Tailwind, Atomic Design, accessibility. Optimized for small LLMs.
compatibility: Qwik, React, Tailwind CSS
metadata:
  author: builderbot
  version: "2.0"
  tags: "design-system, tailwind, atomic-design, accessibility, qwik, react"
---

# Design Elite

> **Para LLMs pequeños:** Lee `QUICKSTART.md` primero para referencia rápida.

## Cuándo Usar
- Auditar/refactorizar componentes UI (React/Qwik)
- Crear componentes enterprise desde cero
- Verificar accesibilidad, Tailwind, Atomic Design

## Protocolo (4 Pasos Obligatorios)

### 1. ESCANEAR
Lista TODOS los archivos del componente/vista (padre + hijos + átomos).

### 2. AUDITAR
Revisa cada archivo contra las **Reglas Críticas** de abajo.

### 3. CORREGIR
Aplica cambios en este orden:
- Fix Qwik serialization (si aplica)
- Fix Tailwind tokens
- Fix átomos vs nativos
- Fix accesibilidad

### 4. VALIDAR
Marca cada item del **Checklist de Cierre**. Si falla algo, vuelve al paso 3.

---

## Reglas Críticas (NUNCA IGNORAR)

### Qwik Serialización
```
✅ PERMITIDO: Pasar strings por props
<Input prefixIcon="search" />

❌ PROHIBIDO: Pasar JSX/funciones por props
<Input prefixIcon={<LuSearch />} />

✅ PERMITIDO: Closure sin captura
onKeyDown$={$((e) => {
  if (e.key === 'Enter') (e.target as HTMLElement).click();
})}

❌ PROHIBIDO: Closure capturando objetos con funciones
onKeyDown$={$((e) => {
  item.action(); // item tiene funciones
})}

❌ PROHIBIDO: t() inline en props o closures
<div aria-label={t('menu.label')} />
const handler = $(() => notify(t('error')))

✅ OBLIGATORIO: Extraer t() antes
const label = t('menu.label');
<div aria-label={label} />
```

### Tailwind Tokens Obligatorios

| Propiedad | Tokens Permitidos | PROHIBIDO |
|-----------|-------------------|-----------|
| **gap** | `gap-1`, `gap-2`, `gap-3`, `gap-4`, `gap-6`, `gap-8` | `gap-2.5`, `gap-3.5`, `gap-5`, `gap-7` |
| **altura controles** | `h-8`, `h-9`, `h-10` | `py-*` solo (sin `h-*`) |
| **bordes light** | `border-gray-200` | `border-gray-100`, `border-gray-300` |
| **bordes dark** | `dark:border-githubDark-border` | `dark:border-gray-600`, `dark:border-gray-700` |
| **valores** | Tokens del DS | Cualquier `[...]` arbitrario |

### Átomos vs Nativos
```
✅ OBLIGATORIO: Usar átomos de ~/atoms
import { Button, Input, Badge } from '~/atoms'
<Button onClick$={handler}>Guardar</Button>
<Input bind:value={signal} />

❌ PROHIBIDO: HTML nativo con clases Tailwind
<button class="bg-blue-600 text-white px-4 py-2">Guardar</button>
<input class="border border-gray-300 px-3 py-2" />
```

### Input bind:value (Spread Condicional)
```tsx
// ✅ OBLIGATORIO: Spread condicional
{...(props['bind:value'] != null && { 'bind:value': props['bind:value'] })}

// ❌ PROHIBIDO: Pasar undefined
bind:value={props['bind:value']}
```

### Accesibilidad
```
✅ OBLIGATORIO: focus-visible en todo interactivo
<button class="focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:outline-none">

✅ OBLIGATORIO: aria-label en icon-only
<button aria-label="Cerrar menú">
  <LuX class="h-4 w-4" />
</button>

❌ PROHIBIDO: outline-none sin alternativa
<button class="outline-none">
```

---

## Checklist de Cierre (Marcar Todos)

- [ ] Sin valores arbitrarios `[...]` en Tailwind
- [ ] Todos los `gap-*` usan tokens DS (`gap-1/2/3/4/6/8`)
- [ ] Controles inline usan `h-*` explícito, nunca solo `py-*`
- [ ] Bordes usan `border-gray-200` o `dark:border-githubDark-border`
- [ ] Sin `t(...)` inline en props o closures `$()`
- [ ] Iconos pasados como string, nunca JSX/funciones
- [ ] `focus-visible` en todo elemento interactivo
- [ ] `aria-label` en botones de solo icono
- [ ] Usando átomos de `~/atoms`, no HTML nativo
- [ ] `bind:value` con spread condicional (si aplica)
- [ ] Skeleton usa mismo `gap-*` que contenido real
- [ ] Modales: título `text-left`, footer `justify-end`, secundario outline

---

## Referencias (Para Detalles)

### Agents (Subagentes Detallados)
- `references/agents/anti-pattern.md` — Tailwind anti-patterns
- `references/agents/dry-atoms.md` — DRY + Qwik serialization
- `references/agents/layout-enforcer.md` — Layout macro
- `references/agents/organism.md` — Organismos (cards, modales, tablas)
- `references/agents/atom-enforcer.md` — Átomos detallados
- `references/agents/motion-feedback.md` — Transiciones y estados
- `references/agents/a11y-enterprise.md` — Accesibilidad WCAG

### Rules (Leyes Específicas)
- `references/rules/qwik-serialization.md`
- `references/rules/tailwind-tokens.md`
- `references/rules/border-consistency.md`
- `references/rules/height-consistency.md`
- `references/rules/spacing-grid.md`
- `references/rules/seamless-design.md`

### Patterns (Ejemplos)
- `references/patterns/button-atom.md` — Patrón Button
- `references/patterns/input-atom.md` — Patrón Input
- `references/patterns/modal-organism.md` — Patrón Modal Vercel-style
- `references/patterns/card-organism.md` — Patrón Card Seamless
- `references/patterns/typography-docs.md` — Tipografía en documentación
- `references/patterns/toc-sidebar.md` — TOC/Sidebar navigation
- `references/patterns/color-semantic.md` — Color semántico en banners

---

## Ejemplo de Salida Esperada

```
## Resumen de Cambios

### Archivo: src/components/user-card.tsx
- [ALTO] Reemplazado <button> nativo por <Button>
- [MEDIO] Cambiado gap-2.5 → gap-4
- [ALTO] Añadido aria-label en icon-only button

### Archivo: src/components/user-list.tsx
- [CRÍTICO] Fix: bind:value usa spread condicional
- [ALTO] Añadido h-9 a Input en toolbar

## Checklist de Cierre
✅ Todos los items marcados
```
