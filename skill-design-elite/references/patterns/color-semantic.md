# Color Semantic Pattern

## 🎨 Ley de Color Semántico — Banners e Info Boxes (LEER SIEMPRE)

> Esta ley aplica en **cualquier fase** cuando se auditen o creen banners, cajas informativas o secciones de aviso.

## El Problema: "Efecto Carnaval"

Cuando una página usa múltiples bloques con colores semánticos (`blue-*`, `amber-*`, `red-*`, `green-*`) al mismo tiempo, el resultado visual es saturado y el usuario pierde la jerarquía de urgencia. Los colores semánticos pierden su significado.

## Regla de Clasificación Semántica

Antes de aplicar color a cualquier bloque, clasificarlo en una de estas 3 categorías:

| Categoría | Condición | Color permitido |
|-----------|-----------|-----------------|
| **Alerta crítica** | El usuario no puede operar correctamente sin resolver el issue (ej: fallo de pago, credenciales inválidas) | `amber-*` o `red-*` |
| **Error de operación** | Una acción falló y necesita feedback inmediato | `red-*` |
| **Informativo** | Explica qué es algo, muestra datos de configuración, tips, instrucciones | Tokens neutros DS únicamente |

**Regla:** Solo los bloques de categoría "alerta crítica" y "error de operación" usan color semántico. **Todo lo informativo usa la paleta neutra del DS.**

## Tokens Canónicos para Bloques Informativos

```tsx
// ✅ Correcto — info box neutral
<section class="rounded-lg border border-gray-200 bg-gray-50 p-4 dark:border-githubDark-border dark:bg-githubDark-surface">
  <h3 class="text-sm font-medium text-gray-900 dark:text-white">Título</h3>
  <p class="mt-1 text-sm text-gray-600 dark:text-githubDark-textTertiary">Descripción</p>
</section>

// ❌ Incorrecto — blue/amber para contenido informativo
<section class="border-blue-200 bg-blue-50 ...">
<section class="border-amber-200 bg-amber-50 ...">
```

## Degradación Interna de Componentes

Cuando un componente informativo tiene partes internas (cards anidadas, tips box, spinner, botones), **todas** deben usar tokens neutros también:

| Elemento | Token |
|----------|-------|
| Card anidada | `bg-white border border-gray-200 dark:bg-githubDark-bg dark:border-githubDark-border` |
| Tips / nota box | `bg-white border border-gray-200 dark:bg-githubDark-bg dark:border-githubDark-border` |
| Spinner | `border-gray-400 dark:border-githubDark-textTertiary` |
| Texto label | `text-gray-600 dark:text-githubDark-textTertiary` |
| CTA link | `border border-gray-200 bg-white hover:bg-gray-50 dark:border-githubDark-border dark:bg-githubDark-bg` |

## Máximo 1 Bloque Semántico por Página

- No uses múltiples banners de colores diferentes en la misma vista.
- Si hay alerta crítica + info + success al mismo tiempo, prioriza la alerta crítica (ámbar/rojo).
- El resto de la información debe usar tokens neutros.

## Colores Prohibidos en Info Boxes

**NO usar para contenido informativo:**
- `bg-blue-50` / `border-blue-200`
- `bg-amber-50` / `border-amber-200`
- `bg-green-50` / `border-green-200`
- `bg-red-50` / `border-red-200`

Estos colores se reservan **exclusivamente** para:
- Blue: Links, información de estado activo
- Amber: Alertas críticas, advertencias importantes
- Green: Éxito, confirmaciones
- Red: Errores, acciones destructivas

## Checklist de Color Semántico

- [ ] Máximo 1 bloque semántico por página (el de mayor urgencia real)
- [ ] Bloques informativos usan tokens neutros DS (`gray-*`, `githubDark-*`) — nunca `blue-*`, `amber-*` para info estática
- [ ] Spinners dentro de paneles informativos: `border-gray-400`, no `border-amber-600` ni `border-blue-600`
- [ ] CTAs dentro de paneles informativos: estilo DS por defecto (blanco + borde gris), no `bg-amber-600` ni `bg-blue-600`
- [ ] Botones de copia/acción secundaria dentro de paneles: sin `classBtn` override de color, usar DS default
- [ ] No hay `bg-blue-50/amber-50/green-50` en secciones informativas (tips, acordeones de config, info boxes)
