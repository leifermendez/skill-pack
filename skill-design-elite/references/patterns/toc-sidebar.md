# TOC/Sidebar Navigation Pattern

## 📐 Ley de Agrupación por Categorías en TOC/Sidebar (LEER SIEMPRE)

> Esta ley aplica cuando se auditen o creen **Table of Contents, sidebars de documentación o listas de navegación** con elementos que tienen subitems.

## Patrón Premium de Agrupación (Estilo Resend/Vercel/Stripe)

Los items de nivel 0 con hijos NO se renderizan como botones navegables simples. Se convierten en **headers de categoría no-clicables** (o clicables pero con estilo de label) que agrupan sus subitems visualmente.

**Estructura:**
```
CATEGORÍA A                ← label uppercase, font-medium, tracking-wider
  Subitem 1                ← font-normal, text-gray-500, indentado
  Subitem 2
──────────────             ← border-b separador
CATEGORÍA B
  Subitem 3
  Subitem 4
──────────────
ITEM SIMPLE                ← items sin hijos = botón clickeable directo
```

## Implementación

```tsx
const renderTOCGroup = (item: TOCItem, isLast: boolean) => {
  // Sin hijos → botón simple
  if (!item.children || item.children.length === 0) {
    return (
      <div class={!isLast ? 'border-b border-gray-200/60 pb-1.5 dark:border-githubDark-border/60' : ''}>
        <button class="w-full text-left px-2.5 py-1.5 text-xs rounded font-medium ...">
          {item.title}
        </button>
      </div>
    );
  }
  // Con hijos → grupo con label de categoría
  return (
    <div class={!isLast ? 'border-b border-gray-200/60 py-2 dark:border-githubDark-border/60' : 'pt-2'}>
      <button class="w-full text-left px-2.5 pb-1.5 text-xs font-medium uppercase tracking-wider text-gray-600 ...">
        {item.title}
      </button>
      <div class="space-y-0.5">
        {item.children.map(child => (
          <button class="w-full text-left py-1.5 px-2.5 text-xs rounded font-normal ...">
            {child.title}
          </button>
        ))}
      </div>
    </div>
  );
};

// En el nav — sin space-y-* en el contenedor (los grupos manejan su propio espaciado)
<nav>{items.map((item, idx) => renderTOCGroup(item, idx === items.length - 1))}</nav>
```

## Tokens de Estilo

### Headers de Categoría (Con Hijos)
- `text-xs font-medium uppercase tracking-wider`
- `text-gray-600 dark:text-githubDark-textTertiary`
- No es un botón navegable directo (o si lo es, usa estilo de label)

### Items Simples (Sin Hijos)
- `text-xs font-medium`
- Botón clickeable directo
- Background highlight cuando está activo

### Subitems
- `text-xs font-normal text-gray-500 dark:text-githubDark-textTertiary`
- Indentación: `ml-2`, `ml-4` (no usar iconos/flechas de jerarquía)

### Separadores
- `border-b border-gray-200/60 dark:border-githubDark-border/60`
- Entre grupos excepto el último
- Sin `space-y-*` en el contenedor padre

### Font Family
- `font-inter` explícito en contenedor raíz
- `font-inter` explícito en cada `<button>` (por Firefox/Safari)

## Separadores en Navegación (Minimalismo)

**Tokens canónicos para separadores sutiles:**

| Uso | Light | Dark |
|-----|-------|------|
| Separador entre secciones | `border-gray-200/60` | `dark:border-githubDark-border/60` |
| Separador antes de CTA/área destacada | `border-t border-gray-200/60` | `dark:border-t dark:border-githubDark-border/60` |

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

## Ley de Color en Navegación — Headers de Grupo/Categoría

> **Los headers de grupo/categoría en navegación lateral usan SIEMPRE tokens neutros del DS. Nunca se asigna un color diferente por categoría.**

### El Problema: "Efecto Carnaval en Navegación"

Asignar un color diferente (azul, violeta, esmeralda, ámbar…) a cada header de grupo en una navegación lateral es **decorativo, no funcional**. Viola la filosofía Seamless porque:

1. Genera ruido visual — el ojo del usuario procesa 4+ tonos en lugar de leer la jerarquía.
2. El color pierde significado semántico — si todo tiene color, nada tiene color.
3. Rompe la neutralidad del Design System en una zona que debe ser utilitaria, no expressiva.

### Regla Absoluta

> **Los headers de grupo/categoría en navegación lateral usan SIEMPRE tokens neutros del DS. Nunca se asigna un color diferente por categoría.**

### Tokens Canónicos para Headers de Grupo

```tsx
// ✅ Correcto — neutral, jerarquía con peso y tamaño, no con color
<span class="text-xs font-medium uppercase tracking-wider text-gray-500 dark:text-githubDark-textTertiary">
  Analytics
</span>

// ❌ Incorrecto — color diferente por categoría (efecto carnaval)
<span class={`text-sm font-semibold ${group.color}`}>   // group.color = 'text-blue-600' / 'text-violet-600' / ...
  Analytics
</span>
```

### Cómo Crear Jerarquía Sin Color

La jerarquía en navegación agrupada se logra **solo** con tipografía y espaciado:

| Nivel | Tokens |
|-------|--------|
| Header de grupo | `text-xs font-medium uppercase tracking-wider text-gray-500 dark:text-githubDark-textTertiary` |
| Item activo | `bg-gray-100 text-gray-900 dark:bg-githubDark-surfaceHover dark:text-gray-100` |
| Item inactivo | `text-gray-500 dark:text-githubDark-textTertiary` |
| Separador entre grupos | `border-b border-gray-200/60 dark:border-githubDark-border/60` |

### Anti-Patrón Prohibido

```tsx
// ❌ Patrón prohibido — color y bgColor diferentes por grupo
const NAV_GROUPS = [
  { id: 'analytics', color: 'text-blue-600 dark:text-blue-400', bgColor: 'bg-blue-50 dark:bg-blue-900/20', ... },
  { id: 'operations', color: 'text-violet-600 dark:text-violet-400', bgColor: 'bg-violet-50 ...', ... },
  { id: 'comms', color: 'text-emerald-600 dark:text-emerald-400', ... },
  { id: 'content', color: 'text-amber-600 dark:text-amber-400', ... },
];

// ✅ Correcto — todos los grupos con el mismo tratamiento neutral
const NAV_GROUPS = [
  { id: 'analytics', label: 'Analytics', items: [...] },
  { id: 'operations', label: 'Operations', items: [...] },
];
// Header de grupo renderizado siempre con: text-xs font-medium uppercase tracking-wider text-gray-500
```

## Checklist Agrupación TOC/Sidebar

- [ ] Items con hijos usan label de categoría (uppercase, tracking-wider), no botón normal
- [ ] Items sin hijos usan botón clickeable directo con estilo consistente
- [ ] Separador `border-b border-gray-200/60` entre grupos excepto el último
- [ ] El contenedor `<nav>` no usa `space-y-*` — el ritmo lo definen los `py-*` internos de cada grupo
- [ ] Sin flecha `→` u otros iconos de jerarquía — la indentación (`ml-2`, `ml-4`) es suficiente
- [ ] Todos los headers de grupo usan **exactamente el mismo** token de color neutro
- [ ] No existe ninguna propiedad `color`, `bgColor` o similar que varíe por grupo
- [ ] `font-inter` explícito en contenedor raíz y en cada button
