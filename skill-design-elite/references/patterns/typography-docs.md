# Typography Documentation Pattern

## 📐 Ley de Tipografía en Páginas de Documentación/API (LEER SIEMPRE)

> Esta ley aplica cuando se auditen o creen páginas de documentación técnica (API Reference, Docs, Changelog, etc.).

## Escala Tipográfica Unificada (3 Niveles)

| Nivel | Token | Uso |
|-------|-------|-----|
| Título de página | `text-xl font-semibold` | Un único `h1` por página (ej. "BuilderBot REST API") |
| Contenido | `text-sm` | `h2`, descripciones, cuerpo, `<pre>` code blocks |
| Metadata | `text-xs` | Labels, badges, celdas de tabla, tabs, navegación sidebar/TOC |

**Regla:** Solo un tamaño de título (`text-xl`). Los `h2` de secciones como "Autenticación" o "Endpoints" usan `text-sm`, no `text-base` ni `text-lg`. Mezclar `text-base` y `text-lg` en h2 es un hallazgo `[ALTO]`.

## Tokens de Peso Tipográfico en Sidebars/TOC

| Elemento | Token |
|----------|-------|
| Header de categoría | `text-xs font-medium uppercase tracking-wider text-gray-600 dark:text-githubDark-textTertiary` |
| Item activo | `text-xs font-medium` (+ background highlight) |
| Subitem inactivo | `text-xs font-normal text-gray-500 dark:text-githubDark-textTertiary` |
| Padding de header | `px-3.5 py-2.5` |

**Regla crítica jerarquía de peso:** Los headers de categoría usan `font-medium`, los subitems usan `font-normal`. Si todos los niveles usan `font-medium` o todos usan el mismo peso, se pierde la jerarquía visual — hallazgo `[ALTO]`.

## Fuente Explícita en Sidebars y Botones (`font-inter`)

Los elementos `<button>` nativos en varios navegadores (Firefox, Safari) **no heredan `font-family` del padre** — usan la fuente del agente de usuario aunque el `div` padre tenga `font-inter`. Esto causa que botones dentro de un TOC o sidebar muestren una fuente diferente a los `<li>` del SideBar principal (que sí heredan correctamente).

**Regla:** Añadir `font-inter` tanto en el contenedor raíz del sidebar/TOC como directamente en cada `<button>`.

```tsx
// ✅ Correcto — font-inter en contenedor Y en cada button
<div class="... font-inter ...">
  <button class="... font-inter text-xs font-medium ...">Item</button>
</div>

// ❌ Incorrecto — solo en el contenedor; los buttons de algunos browsers ignorarán la herencia
<div class="... font-inter ...">
  <button class="... text-xs font-medium ...">Item</button>
</div>
```

**Causa raíz:** CSS `font-family` es una propiedad heredada, pero los navegadores aplican `font-family` vía el user-agent stylesheet sobre form elements (`button`, `input`, `select`, `textarea`) con mayor especificidad que la herencia. El reset de Tailwind (preflight) no corrige esto para `font-family`.

## Checklist Tipografía Documentación

- [ ] Un solo `text-xl` para el `h1` principal de la página
- [ ] Todos los `h2` de sección usan `text-sm` (no `text-base`, `text-lg`)
- [ ] Metadata, labels y navegación usan `text-xs`
- [ ] Headers de categoría: `font-medium`; subitems: `font-normal`
- [ ] Sidebars tienen `font-inter` explícito en el contenedor raíz
- [ ] Botones dentro de sidebars también tienen `font-inter` explícito
