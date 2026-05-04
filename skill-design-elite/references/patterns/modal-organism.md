# Modal Organism Pattern

## Modales Vercel-Style (Strict Knowledge)

Los modales deben seguir un estándar estricto de minimalismo y profesionalismo para mantener una estética 10/10.

## Encabezados Limpios

- **Prohibido** el uso de `text-center` y la inclusión de grandes íconos de colores circulares en el encabezado.
- El título debe estar alineado a la izquierda (`text-left`) con un peso tipográfico contundente:
  - `text-xl font-semibold tracking-tight`

## Botones Secundarios

- Los botones como "Cancelar" o "Cerrar" en los footers NO deben ser simples textos ("ghost").
- Deben usar un estilo delineado (Outlined) limpio:
  - Light: `border border-gray-200 bg-white text-gray-700 hover:bg-gray-50 shadow-sm`
  - Dark: `dark:border-githubDark-border dark:bg-githubDark-bg dark:text-githubDark-text dark:hover:bg-githubDark-surface`
- Esto balancea el peso visual contra el botón primario.

## Alineación del Footer

- Los botones de acción deben agruparse a la derecha: `justify-end gap-3`
- El botón secundario (Cancelar) siempre a la izquierda del botón principal (Confirmar)

## Reducción de Líneas Duras

- Evitar las divisiones rígidas como los `border-b` en los headers.
- Preferir separar visualmente mediante espacios en blanco (`padding`).
- Si se necesita una separación en el footer, que sea sumamente sutil:
  - `border-t border-gray-100` combinado con padding `pt-4 mt-2`

## Estructura Completa

```tsx
// ✅ Modal Vercel-style correcto
<div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
  <div class="w-full max-w-md rounded-xl bg-white shadow-xl dark:bg-githubDark-bg">
    {/* Header — sin border, solo padding */}
    <div class="px-6 pt-6">
      <h2 class="text-xl font-semibold tracking-tight text-gray-900 dark:text-white">
        Confirmar Acción
      </h2>
    </div>
    
    {/* Step indicator (si aplica) — aquí va el único border-b */}
    <div class="border-b border-gray-200 px-6 py-3 dark:border-githubDark-border">
      <StepIndicator steps={3} current={1} />
    </div>
    
    {/* Content */}
    <div class="px-6 py-4">
      <p class="text-gray-600 dark:text-githubDark-textSecondary">
        ¿Estás seguro de que deseas continuar?
      </p>
    </div>
    
    {/* Footer — alineado a la derecha */}
    <div class="flex justify-end gap-3 border-t border-gray-100 px-6 py-4 dark:border-githubDark-border">
      <Button classBtn="border border-gray-200 bg-white text-gray-700 hover:bg-gray-50 dark:border-githubDark-border dark:bg-githubDark-bg dark:text-githubDark-text">
        Cancelar
      </Button>
      <Button classBtn="!bg-blue-600 !text-white hover:!bg-blue-700">
        Confirmar
      </Button>
    </div>
  </div>
</div>
```

## Checklist de Modal

- [ ] Título alineado a la izquierda (`text-left`)
- [ ] Sin iconos grandes de colores en el header
- [ ] Botón secundario usa estilo outline (no ghost)
- [ ] Footer con botones agrupados a la derecha (`justify-end`)
- [ ] Cancelar a la izquierda, Confirmar a la derecha
- [ ] Separaciones sutiles con padding, no borders rígidos
- [ ] Si hay border, solo uno entre header y content (en step-indicator si aplica)
- [ ] Fondo con backdrop blur: `backdrop-blur-sm bg-black/50`

## Anti-Patrón Prohibido

```tsx
// ❌ Incorrecto — icono gigante centrado, botón ghost
<div class="modal">
  <div class="text-center">
    <div class="bg-amber-100 rounded-full p-4">
      <LuAlertTriangle class="h-12 w-12 text-amber-600" />
    </div>
    <h2 class="text-xl font-semibold">Atención</h2>
  </div>
  <div class="footer">
    <button class="text-gray-500 hover:text-gray-700">Cancelar</button>
    <button class="bg-blue-600 text-white">Confirmar</button>
  </div>
</div>
```
