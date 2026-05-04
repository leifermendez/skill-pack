# Seamless Design Principles

## Pilar de Diseño: Seamless (Estilo Vercel)

Tu filosofía central es el diseño "Seamless" (sin costuras): interfaces que fluyen naturalmente, minimizando el ruido visual. Priorizas la reducción de bordes duros innecesarios y sombras pesadas, apostando por el uso del espacio en blanco, contrastes sutiles de fondo y "glassmorphism" para elementos fijos.

## Nota sobre Modales

Aplica estrictamente el "Modo Vercel" en modales: textos alineados a la izquierda, sin iconos gigantes en encabezados, botones secundarios tipo "outline" y agrupados a la derecha.

## Principios Seamless

### 1. Reducción de Ruido Visual
- Minimizar bordes duros innecesarios.
- Preferir espacio en blanco sobre separadores visuales.
- Usar contrastes sutiles de fondo en lugar de bordes.

### 2. Glassmorphism en Elementos Fijos
Todo elemento flotante o fijo en el layout (headers, barras superiores, toolbars fijos) debe usar **glassmorphism** en lugar de colores sólidos opacos.

- Exige el uso de `backdrop-blur-md bg-white/70` (o `bg-white/80`) en light mode.
- Exige el uso de `backdrop-blur-md dark:bg-githubDark-bg/70` (o la variante surface) en dark mode.
- Esto asegura que al hacer scroll, el contenido pase de forma fluida por debajo de la barra.

### 3. Sombras Suaves
- Reducir la dependencia de `shadow-md` o sombras pesadas.
- Promover el uso exclusivo de `shadow-sm` con bordes muy sutiles (`border-gray-200/40` o `border-transparent`).
- **Hover effects:** Los bordes o sombras pueden acentuarse ligeramente al hacer `hover` (ej. `hover:border-gray-300 hover:shadow-md transition-all`), manteniendo el reposo "Seamless".

### 4. Integración de Skeletons
Los skeletons deben ser "Seamless". Usa colores difusos (`bg-gray-200/50` o `dark:bg-githubDark-surface/50`) que se integren de forma natural con el fondo, sin verse como bloques toscos y opacos de alto contraste.

## Tinted Glass Announcement Bars (Patrón 2025/2026)

Cuando audites o crees una barra de anuncios (`top-announcement`, `hello bar`):
- **Prohibido** usar colores sólidos vibrantes opacos (ej. `bg-amber-500` o gradientes rígidos) que saturen el layout.
- **Exigir Patrón Tinted Glass**:
  - **Fondo:** Color de marca o semántico ultra-translúcido (ej. `bg-amber-500/15` o `bg-primary-100/15`) combinado con `backdrop-blur-md`.
  - **Borde:** Un ring o borde sutil del mismo tono (`border-amber-500/25`).
  - **Estructura:** Texto centrado visualmente (ambos flancos de igual ancho, usando ícono a la izquierda y botón *close* a la derecha).
  - Esto inyecta color e intención sin perder la modernidad del "frosted glass".

## Separadores en Sidebar y Layouts (Seamless Dividers)

Cuando audites un Sidebar o menú de navegación lateral, exige separadores "Seamless" para jerarquía visual sin saturar.

**Regla Seamless:** Reemplazar líneas divisorias duras (`border-b`, `border-t`) por espacios en blanco (`gap`, `mb`) o cambios de fondo sutiles (`bg-gray-50`, `dark:bg-githubDark-surface`) cuando sea posible.

Si el border es indispensable:
- **Entre secciones:** `border-b border-gray-200/60 dark:border-githubDark-border/60` en cada sección excepto la última.
- **Antes de CTA/notificaciones:** `border-t border-gray-200/60 pt-2 dark:border-githubDark-border/60`.
- Usar `gap-0` en el contenedor padre; el ritmo lo definen `border-*` y `py-*`/`pt-*`.

## Modales Vercel-Style (Strict Knowledge)

Los modales deben seguir un estándar estricto de minimalismo y profesionalismo para mantener una estética 10/10:

### Encabezados Limpios
- Prohibido el uso de `text-center` y la inclusión de grandes íconos de colores circulares en el encabezado.
- El título debe estar alineado a la izquierda (`text-left`) con un peso tipográfico contundente (ej. `text-xl font-semibold tracking-tight`).

### Botones Secundarios
- Los botones como "Cancelar" o "Cerrar" en los footers NO deben ser simples textos ("ghost").
- Deben usar un estilo delineado (Outlined) limpio: `border border-gray-200 bg-white text-gray-700 hover:bg-gray-50 shadow-sm` (con su variante equivalente en modo oscuro).
- Esto balancea el peso visual contra el botón primario.

### Alineación del Footer
- Los botones de acción deben agruparse a la derecha (`justify-end gap-3`).
- El botón secundario (Cancelar) siempre a la izquierda del botón principal (Confirmar).

### Reducción de Líneas Duras
- Evitar las divisiones rígidas como los `border-b` en los headers.
- Preferir separar visualmente mediante espacios en blanco (`padding`).
- Si se necesita una separación en el footer, que sea sumamente sutil (`border-t border-gray-100` combinado con padding `pt-4 mt-2`).

## Checklist Seamless

- [ ] Se aplicó reducción de ruido visual: sin sombras pesadas, bordes sutiles.
- [ ] Barras de anuncio (Top bars) usan el patrón **Tinted Glass**: fondo color-translúcido + `backdrop-blur-md` (ej. `bg-amber-500/15`), prohibido colores vibrantes opacos.
- [ ] Tarjetas con contenido compacto: sin `min-h-*` forzado, sin `flex-1` ni `h-full` que generen espaciado vacío.
- [ ] Elementos fijos (headers) usan glassmorphism: `backdrop-blur-md bg-white/70`.
- [ ] Separadores en sidebars usan `/60` para sutileza: `border-gray-200/60`.
- [ ] Modales siguen estilo Vercel: título alineado a la izquierda, botones outline agrupados a la derecha.
