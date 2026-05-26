# CSS Architecture Patterns Reference

## Atomic Design

**Structure:**
```
components/
  atoms/
    Button/
    Input/
    Label/
    Icon/
  molecules/
    SearchBar/
    FormField/
    Card/
  organisms/
    Header/
    Hero/
    Footer/
    ProductGrid/
  templates/
    HomeTemplate/
    ProductTemplate/
  pages/
    HomePage/
    ProductPage/
```

**Naming:** Component names are PascalCase, folders indicate level.
**Indicators:** Folders named `atoms`, `molecules`, `organisms`, `templates`, `pages`.

## BEM (Block Element Modifier)

**Naming Convention:**
- Block: `.button`
- Element: `.button__icon`, `.button__text`
- Modifier: `.button--primary`, `.button--large`, `.button--disabled`

**Pattern:** `^[a-z][a-z0-9-]*__[a-z][a-z0-9-]*(--[a-z][a-z0-9-]*)?$`

**Example:**
```css
.card { }
.card__title { }
.card__content { }
.card--featured { }
.card--dark { }
```

## SMACSS (Scalable and Modular Architecture for CSS)

**Categories:**
1. **Base** - Reset/normalize, HTML element defaults
2. **Layout** - Grid systems, major layout components
3. **Module** - Reusable components (nav, button, card)
4. **State** - Active/inactive, collapsed/expanded
5. **Theme** - Color schemes, typography

**Structure:**
```
css/
  base/
    reset.css
    typography.css
  layout/
    grid.css
    header.css
  modules/
    button.css
    card.css
  states/
    active.css
    collapsed.css
  themes/
    dark.css
    light.css
```

## ITCSS (Inverted Triangle CSS)

**Layers (from generic to specific):**
1. **Settings** - Variables, config (no output)
2. **Tools** - Mixins, functions (no output)
3. **Generic** - Resets, normalize, box-sizing
4. **Elements** - Unclassed HTML elements (h1, a, p)
5. **Objects** - OOCSS objects (layout patterns)
6. **Components** - UI components (button, card)
7. **Trumps** - Utilities, helpers, overrides

**Structure:**
```
styles/
  settings/
    _colors.scss
    _typography.scss
  tools/
    _mixins.scss
    _functions.scss
  generic/
    _normalize.scss
    _reset.scss
  elements/
    _headings.scss
    _links.scss
  objects/
    _layout.scss
    _media.scss
  components/
    _button.scss
    _card.scss
  trumps/
    _utilities.scss
    _overrides.scss
```

## OOCSS (Object-Oriented CSS)

**Principles:**
1. **Separation of Structure from Skin** - Layout vs. Theme
2. **Separation of Container from Content** - Context-independent modules

**Example:**
```css
/* Structure */
.media { display: flex; }
.media__img { margin-right: 1rem; }
.media__body { flex: 1; }

/* Skin */
.theme-blue { background: blue; color: white; }
.theme-red { background: red; color: white; }
```

## Utility-First (Tailwind-like)

**Characteristics:**
- Single-purpose classes
- No component classes
- Configuration-driven
- JIT compilation

**Example:**
```html
<div class="flex items-center justify-center p-4 m-2 bg-blue-500 text-white rounded-lg shadow-md">
```

**Detection:**
- High frequency of short class names (flex, pt-4, text-center)
- Presence of `tailwind.config.*`
- `@tailwind` directives in CSS

## CSS Modules

**Characteristics:**
- Scoped styles per component
- camelCase or BEM-like naming
- `.module.css` extension
- Hash in class names at build time

**Example:**
```css
/* Button.module.css */
.button { }
.buttonPrimary { }
.buttonLarge { }
```

## CSS-in-JS

**Libraries:** styled-components, Emotion, Linaria, vanilla-extract

**Detection:**
- `package.json` dependencies
- Template literals with CSS
- Dynamic prop-based styling

**Example (styled-components):**
```jsx
const Button = styled.button`
  background: ${props => props.primary ? 'blue' : 'gray'};
  padding: 1rem;
`;
```

## Confidence Scoring

| Methodology | Folder Structure | Naming Patterns | File Organization |
|-------------|-----------------|-----------------|-----------------|
| Atomic | 40% | 20% | 40% |
| BEM | 10% | 60% | 30% |
| SMACSS | 40% | 20% | 40% |
| ITCSS | 40% | 20% | 40% |
| OOCSS | 10% | 40% | 50% |
| Utility | 10% | 70% | 20% |
| Modules | 20% | 40% | 40% |

## Hybrid Approaches

Many modern projects combine methodologies:
- **Atomic + BEM:** Atomic folder structure with BEM naming
- **ITCSS + BEM:** ITCSS layers with BEM components
- **Utility + Components:** Tailwind utilities + component classes

When detecting, report **primary** and **secondary** methodologies with confidence scores.
