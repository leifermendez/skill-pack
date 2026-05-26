---
name: skill-frontend-design-scanner
description: "Trigger: scan design system, detect CSS architecture, analyze frontend tokens, detect Tailwind, BEM, Atomic Design. Scan projects for design system patterns, component trees, and branding tokens."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Skill: frontend-design-scanner

## Activation Contract

Activate this skill when the user needs to:
- **Scan** a frontend codebase to understand its **design system** and **CSS architecture**
- **Detect** the presence and version of **Tailwind CSS**, **CSS frameworks**, or **preprocessors**
- **Identify** the design methodology: **Atomic Design**, **BEM**, **SMACSS**, **ITCSS**, **OOCSS**, or utility-first
- **Extract** branding tokens: fonts, sizes, weights, border radius, colors, spacing scales
- **Map** the component hierarchy and identify base components (buttons, inputs, selects, textareas)
- **Audit** the consistency of design tokens across the codebase

Do not activate for pure backend projects or when only trivial CSS is present.

## Hard Rules

1. **Always use the detection scripts** in `assets/` when scanning; do not rely solely on file inspection.
2. **Never assume** the architecture; detect it from class naming patterns, folder structure, and config files.
3. **Report confidence levels** for each detection (High / Medium / Low).
4. **Prefer AST parsing** over regex when analyzing CSS/SCSS/JSX/Vue/Svelte files.
5. **Normalize** all extracted tokens into a standard JSON schema defined in `assets/token-schema.json`.
6. **Respect** `.gitignore` and skip `node_modules`, `.next`, `dist`, `build` folders.

## Decision Gates

| Situation | Action |
|-----------|--------|
| Tailwind config found (`tailwind.config.*`) | Use `detect-tailwind.js` to extract version, theme, plugins, customizations |
| No Tailwind, but CSS/SCSS modules found | Use `detect-css-architecture.js` to identify BEM, SMACSS, ITCSS, or Atomic patterns |
| Component files found (`.jsx`, `.tsx`, `.vue`, `.svelte`) | Use `detect-component-tree.js` to map hierarchy and identify atomic levels |
| CSS variables or SCSS variables found | Use `extract-tokens.js` to extract fonts, colors, spacing, radius |
| Styled-components or Emotion detected | Use `detect-css-in-js.js` to extract dynamic tokens and component patterns |
| Multiple conflicting methodologies found | Report all with confidence scores; flag potential tech debt |

## Execution Steps

### Phase 1: Environment Detection (5 steps)

1. **Detect CSS Frameworks & Tools**
   - Check `package.json` for: `tailwindcss`, `postcss`, `sass`, `less`, `styled-components`, `@emotion/*`, `bootstrap`, `bulma`, `foundation`
   - Check for config files: `tailwind.config.js|ts`, `postcss.config.js`, `vite.config.*`, `webpack.config.*`
   - Record versions from `package.json` or lock files
   - Report: framework name, version, config location

2. **Detect Tailwind CSS Specifics** (Ultra-Precise)
   - Check `package.json` for `tailwindcss` version (v2, v3, v4)
   - Detect v4: CSS-based config with `@import "tailwindcss"` and `@theme` directives
   - Detect v3: `tailwind.config.js|ts|mjs|cjs` with `theme.extend`
   - Extract theme variables:
     - **v4**: Parse CSS for `--color-*`, `--font-*`, `--spacing-*`, `--radius-*`, `--shadow-*`, `--breakpoint-*`
     - **v3**: Parse JS config for `theme.extend.colors`, `fontFamily`, `spacing`, `borderRadius`
   - Detect plugins: `@tailwindcss/forms`, `@tailwindcss/typography`, `tailwindcss-animate`
   - Classify customization level: `default` | `light` | `moderate` | `heavy`
   - Report: version, config type (js-config vs css-config), theme summary, customizations

3. **Detect CSS Architecture Methodology**
   - Scan all `.css`, `.scss`, `.less`, `.sass`, `.styl` files
   - Look for naming patterns:
     - **BEM**: `.block__element--modifier` pattern
     - **Atomic Design**: folders named `atoms/`, `molecules/`, `organisms/`, `templates/`, `pages/`
     - **SMACSS**: folders named `base/`, `layout/`, `module/`, `state/`, `theme/`
     - **ITCSS**: folders named `settings/`, `tools/`, `generic/`, `elements/`, `objects/`, `components/`, `trumps/`
     - **OOCSS**: separation of structure and skin patterns
     - **Utility-first**: prevalence of single-purpose classes (e.g., `flex`, `pt-4`, `text-center`)
   - Calculate methodology confidence score based on:
     - Folder structure matches (40%)
     - Class naming patterns (40%)
     - File organization (20%)
   - Report: primary methodology, secondary methodology (if any), confidence scores

4. **Detect Component Architecture**
   - Scan component files (`.jsx`, `.tsx`, `.vue`, `.svelte`, `.astro`)
   - Build dependency graph (imports/exports)
   - Identify atomic levels if Atomic Design is detected:
     - Atoms: basic HTML wrappers (Button, Input, Label)
     - Molecules: composed atoms (SearchBar, FormField)
     - Organisms: complex sections (Header, Hero, Footer)
     - Templates: page layouts
     - Pages: route components
   - Report: component tree depth, component count by level, most reused components

5. **Detect Base Components**
   - Search for component patterns matching:
     - **Buttons**: `Button`, `Btn`, `button`, `ActionButton`
     - **Inputs**: `Input`, `TextField`, `TextInput`, `FormInput`
     - **Selects**: `Select`, `Dropdown`, `SelectField`
     - **Textareas**: `Textarea`, `TextArea`, `TextField` (multiline)
     - **Labels**: `Label`, `FormLabel`
     - **Checkboxes/Radios**: `Checkbox`, `Radio`, `Switch`, `Toggle`
   - Extract their props interfaces to detect variant systems
   - Report: component locations, variant systems, prop signatures

### Phase 2: Token Extraction (4 steps)

6. **Extract Font Tokens**
   - Parse CSS/SCSS for `font-family`, `@font-face`, CSS variables like `--font-*`
   - Check `tailwind.config.js` theme.fontFamily
   - Extract: font families, fallback stacks, font weights used (400, 500, 700), font styles (italic, normal)
   - Report: primary font, secondary font, monospace font, all weights, all sizes

7. **Extract Font Size Tokens**
   - Parse CSS for `font-size` declarations
   - Check Tailwind config `theme.fontSize` or CSS vars `--text-*`, `--font-size-*`
   - Normalize to pixel or rem values
   - Report: all sizes sorted ascending, base size, scale ratio

8. **Extract Border Radius Tokens**
   - Parse CSS for `border-radius` declarations
   - Check Tailwind config `theme.borderRadius` or CSS vars `--radius-*`, `--rounded-*`
   - Report: all radius values, common patterns (0, 4px, 8px, 9999px/pill)

9. **Extract Color Tokens**
   - Parse CSS for color declarations: `color`, `background-color`, `border-color`
   - Check CSS variables: `--color-*`, `--primary`, `--secondary`, `--bg-*`
   - Check Tailwind config `theme.colors`, `theme.extend.colors`
   - Report: primary, secondary, accent, neutrals, semantic colors (success, error, warning), dark mode colors

### Phase 3: Analysis & Reporting (3 steps)

10. **Analyze Consistency**
    - Check if border radius values are consistent with component types
    - Verify font sizes follow a modular scale
    - Detect hardcoded values vs token-based values
    - Report: consistency score, hardcoded value locations, token coverage percentage

11. **Generate Token Map**
    - Output standardized JSON following `assets/token-schema.json`
    - Include metadata: framework, architecture, confidence, scan timestamp
    - Group tokens by category: `colors`, `typography`, `spacing`, `borders`, `shadows`

12. **Summarize & Recommend**
    - Generate executive summary: 3-5 bullet points of key findings
    - Flag inconsistencies or tech debt
    - Recommend next steps: token consolidation, migration to CSS vars, Tailwind config cleanup, etc.

## Output Contract

Return a structured report containing:

```json
{
  "scan_summary": {
    "project_path": "string",
    "frameworks": [{"name": "string", "version": "string", "config_path": "string"}],
    "css_architecture": {
      "primary": "string",
      "secondary": "string|null",
      "confidence": "number"
    },
    "component_stats": {
      "total": "number",
      "by_level": {"atoms": "number", "molecules": "number", "organisms": "number"},
      "base_components": {
        "buttons": ["string"],
        "inputs": ["string"],
        "selects": ["string"],
        "textareas": ["string"]
      }
    }
  },
  "tokens": {
    "fonts": {
      "families": [{"name": "string", "fallback": "string", "source": "string"}],
      "sizes": [{"value": "string", "px": "number", "usage_count": "number"}],
      "weights": ["number"],
      "styles": ["string"]
    },
    "border_radius": [{"value": "string", "px": "number", "usage_count": "number"}],
    "colors": {
      "primary": "string",
      "secondary": "string",
      "accent": "string",
      "neutrals": ["string"],
      "semantic": {"success": "string", "error": "string", "warning": "string"}
    }
  },
  "analysis": {
    "consistency_score": "number",
    "hardcoded_values": [{"file": "string", "line": "number", "value": "string"}],
    "token_coverage": "number",
    "recommendations": ["string"]
  }
}
```

Also return:
- Files created or modified
- Detection confidence levels for each section
- Any errors or skipped files

## Enhanced Detection Features (v2.0)

### 1. Framework UI Detection
Automatically detects popular Tailwind-based component libraries:
- **shadcn/ui** - Via `class-variance-authority` or `components/ui` folder
- **Radix UI** - `@radix-ui/react-*` packages
- **DaisyUI** - `daisyui` package
- **Flowbite** - `flowbite` and `flowbite-react`
- **Headless UI** - `@headlessui/react` (official)
- **Tailwind UI** - `@tailwindcss/ui`
- **Animation libraries** - `framer-motion`, `tailwindcss-animate`

### 2. Real Usage Analysis
Scans source files to detect:
- **All Tailwind classes used** with frequency count
- **Arbitrary values** - `w-[123px]`, `bg-[#1da1f2]`
- **Responsive prefixes** - `sm:`, `md:`, `lg:` usage stats
- **Dark mode classes** - `dark:` prefix usage
- **Hardcoded values** - Colors outside of theme
- **Token coverage** - Percentage of custom tokens being used
- **Top 20 most used classes**

### 3. Base Component Detection
Identifies common UI components by filename and content:
- **Buttons** - `button`, `btn`, `action-button`
- **Inputs** - `input`, `text-field`, `form-input`
- **Selects** - `select`, `dropdown`, `autocomplete`
- **Textareas** - `textarea`, `text-area`
- **Cards** - `card`, `info-card`
- **Modals** - `modal`, `dialog`, `overlay`
- **Tables** - `table`, `data-table`
- **Navigation** - `nav`, `navbar`, `sidebar`
- **Tabs** - `tabs`, `tab-list`
- **Alerts** - `alert`, `toast`, `notification`
- **Badges** - `badge`, `tag`, `pill`
- **Avatars** - `avatar`, `user-avatar`
- **Tooltips** - `tooltip`, `popover`

## FAANG & Big Tech Patterns

Based on research of major tech companies' design systems:

| Company | Framework | Token System | Architecture | Detection Method |
|---------|-----------|--------------|--------------|-----------------|
| **Meta** | StyleX | `stylex.defineVars()` | Atomic CSS compiled at build time | `assets/detect-css-in-js.js` + StyleX patterns |
| **Google** | Material Design | CSS custom properties (`--mdc-theme-*`) | SCSS + BEM | `assets/detect-css-architecture.js` + MDC patterns |
| **Amazon** | Style Dictionary | JSON tokens (`tokens/**/*.json`) | CTI hierarchy (Category/Type/Item) | `assets/extract-tokens.js` + SD config detection |
| **Netflix** | Custom | CSS variables | Atomic Design | `assets/detect-component-tree.js` + atom folders |
| **Airbnb** | Lunar | TypeScript theme objects | Component co-location | `assets/detect-css-in-js.js` + TS interfaces |
| **Apple** | HIG | Asset catalogs | Platform-specific | File extension detection (`.xcassets`) |

### Key Learnings from FAANG

1. **Atomic CSS Dominance**: All major companies use or are migrating to atomic/utility CSS (Meta's StyleX reduced CSS by 80%)
2. **Build-Time Compilation**: Styles are co-located with components but compiled/transformed at build time
3. **Design Tokens Standardization**: JSON-first token definitions (Amazon Style Dictionary) or CSS variables (Meta, Google)
4. **Theme Support**: CSS custom properties for runtime theming (dark mode, brand switching)
5. **Component Co-location**: Styles live next to components, never in separate global CSS files
6. **Confidence Scoring**: Use folder structure (40%), naming patterns (40%), file organization (20%) for detection

### Enhanced Detection Priority

1. **Meta/StyleX**: Detect `@stylexjs/stylex`, `stylex.create()`, `stylex.defineVars()`
2. **Google/Material**: Detect `@material/*`, `.mdc-*` classes, `--mdc-theme-*` variables
3. **Amazon/Tokens**: Detect `style-dictionary` dependency, `tokens/` folder, `config.json`
4. **Tailwind**: Detect `tailwind.config.*`, `@tailwind` directives, utility classes
5. **BEM/Atomic**: Detect folder structure and naming patterns
6. **CSS-in-JS**: Detect `styled-components`, `@emotion/*`, `linaria`

## References

- `assets/detect-tailwind.js` — Tailwind CSS detection and parsing script
- `assets/detect-css-architecture.js` — CSS methodology detection (BEM, Atomic, SMACSS, ITCSS)
- `assets/detect-component-tree.js` — Component hierarchy and base component detection
- `assets/extract-tokens.js` — Token extraction from CSS/SCSS/JSX/Vue
- `assets/detect-css-in-js.js` — CSS-in-JS library detection (styled-components, Emotion, StyleX)
- `assets/token-schema.json` — Standardized token output schema
- `references/architectures.md` — CSS architecture patterns reference
- `references/tailwind-detection.md` — Tailwind-specific detection patterns
- `references/faang-patterns.md` — FAANG design system patterns and detection algorithms
