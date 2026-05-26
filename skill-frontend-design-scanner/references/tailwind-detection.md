# Tailwind CSS Ultra-Precise Detection Reference (Enhanced v2.0)

## Version Detection

### Tailwind v2
- `package.json`: `"tailwindcss": "^2.x"`
- Config: `tailwind.config.js` (CommonJS)
- Features: `purge` array, `darkMode: 'media'|'class'`
- No JIT by default

### Tailwind v3
- `package.json`: `"tailwindcss": "^3.x"`
- Config: `tailwind.config.js|ts|mjs|cjs`
- Features: `content` array (replaces `purge`), JIT by default
- Plugins: `@tailwindcss/forms`, `@tailwindcss/typography`, etc.

### Tailwind v4 (2024+)
- `package.json`: `"tailwindcss": "^4.x"` OR `@tailwindcss/postcss`, `@tailwindcss/vite`
- Config: CSS-based (NO `tailwind.config.js`)
- Entry: CSS file with `@import "tailwindcss"`
- Theme: `@theme { --color-*: ... }` directives
- Features: CSS variables, `@layer`, native cascade layers

## Framework UI Detection

### shadcn/ui
```javascript
// Detection signals:
// 1. Package: class-variance-authority
// 2. Folder: components/ui/ with button.tsx, input.tsx, etc.
// 3. Components use: cn() utility for class merging

const shadcnIndicators = {
  packages: ['class-variance-authority', 'clsx', 'tailwind-merge'],
  folders: ['components/ui', 'app/components/ui', 'src/components/ui'],
  files: ['button.tsx', 'input.tsx', 'dialog.tsx', 'card.tsx']
};
```

### Radix UI
```javascript
// Detection signals:
// 1. Packages: @radix-ui/react-dialog, @radix-ui/react-select, etc.
// 2. Unstyled primitives with Tailwind classes

const radixIndicators = {
  packages: [
    '@radix-ui/react-dialog',
    '@radix-ui/react-select',
    '@radix-ui/react-dropdown-menu',
    '@radix-ui/react-tabs',
    '@radix-ui/react-tooltip',
    '@radix-ui/react-avatar',
    '@radix-ui/react-alert-dialog',
    '@radix-ui/react-popover'
  ]
};
```

### DaisyUI
```javascript
// Detection signals:
// 1. Package: daisyui
// 2. Plugin in tailwind.config.js
// 3. Classes: btn, card, modal, tabs (semantic names)

const daisyUIIndicators = {
  package: 'daisyui',
  plugin: 'daisyui',
  classes: ['btn', 'card', 'modal', 'tabs', 'tab', 'alert', 'badge']
};
```

### Flowbite
```javascript
// Detection signals:
// 1. Packages: flowbite, flowbite-react
// 2. JavaScript interactive components

const flowbiteIndicators = {
  packages: ['flowbite', 'flowbite-react'],
  classes: ['flowbite'] // data attributes
};
```

### Headless UI (Official)
```javascript
// Detection signals:
// 1. Package: @headlessui/react or @headlessui/vue
// 2. Unstyled accessible components

const headlessUIIndicators = {
  packages: ['@headlessui/react', '@headlessui/vue'],
  components: ['Dialog', 'Menu', 'Listbox', 'Switch', 'Disclosure', 'Popover']
};
```

## Usage Analysis Patterns

### Tailwind Class Detection
```javascript
// Regex patterns for class extraction
const patterns = {
  // Standard utilities: flex, pt-4, text-center
  standard: /\b([a-z]+-[^\s"'`]+)/g,
  
  // Arbitrary values: w-[123px], bg-[#1da1f2], top-[calc(100%-4rem)]
  arbitrary: /\b([a-z]+-\[[^\]]+\])/g,
  
  // Responsive: sm:, md:, lg:, xl:, 2xl:
  responsive: /\b(sm|md|lg|xl|2xl):/g,
  
  // Dark mode: dark:
  darkMode: /\bdark:([a-z-]+)/g,
  
  // Hover/focus states: hover:, focus:, active:
  states: /\b(hover|focus|active|disabled|checked):/g,
  
  // Important modifier: !pt-4
  important: /\!([a-z-]+)/g
};
```

### Usage Statistics Calculation
```javascript
function calculateUsageStats(classes) {
  const stats = {
    totalClasses: classes.length,
    uniqueClasses: new Set(classes).size,
    
    // Category breakdown
    layout: classes.filter(c => /^(flex|grid|block|inline|hidden|float|clear|object-|overflow)/.test(c)),
    spacing: classes.filter(c => /^(p|m|px|py|mx|my|pt|pr|pb|pl|mt|mr|mb|ml|gap|space)-/.test(c)),
    sizing: classes.filter(c => /^(w|h|min-w|max-w|min-h|max-h)-/.test(c)),
    typography: classes.filter(c => /^(text|font|leading|tracking|whitespace|break|truncate)/.test(c)),
    colors: classes.filter(c => /^(bg|text|border|fill|stroke|from|to|via)-/.test(c)),
    borders: classes.filter(c => /^(rounded|border|outline|ring|shadow)/.test(c)),
    effects: classes.filter(c => /^(opacity|mix-blend|bg-blur|backdrop|filter|brightness|contrast)/.test(c)),
    transforms: classes.filter(c => /^(rotate|scale|skew|translate|transform)/.test(c)),
    animations: classes.filter(c => /^(animate|transition|duration|delay|ease|keyframes)/.test(c)),
    interactivity: classes.filter(c => /^(cursor|pointer-events|resize|select|caret|accent)/.test(c))
  };
  
  return stats;
}
```

## Base Component Detection

### Component Patterns by File/Content
```javascript
const componentPatterns = {
  buttons: {
    filenames: ['button', 'btn', 'action-button', 'icon-button', 'submit-button', 'ghost-button', 'outline-button'],
    classPatterns: ['btn', 'button', 'inline-flex items-center justify-center', 'rounded-md font-medium'],
    props: ['variant', 'size', 'disabled', 'loading', 'onClick']
  },
  
  inputs: {
    filenames: ['input', 'text-field', 'text-input', 'form-input', 'number-input', 'password-input', 'email-input'],
    classPatterns: ['input', 'form-input', 'w-full px-3 py-2 border rounded-md'],
    props: ['type', 'placeholder', 'disabled', 'error', 'onChange']
  },
  
  selects: {
    filenames: ['select', 'dropdown', 'select-field', 'multi-select', 'autocomplete', 'combobox'],
    classPatterns: ['select', 'dropdown'],
    props: ['options', 'value', 'onChange', 'placeholder', 'multiple']
  },
  
  textareas: {
    filenames: ['textarea', 'text-area', 'long-text-input', 'message-input', 'comment-box'],
    classPatterns: ['textarea', 'w-full px-3 py-2 border rounded-md resize-none'],
    props: ['rows', 'placeholder', 'maxLength', 'onChange']
  },
  
  cards: {
    filenames: ['card', 'info-card', 'product-card', 'feature-card', 'stat-card'],
    classPatterns: ['card', 'rounded-lg border bg-white shadow-sm', 'rounded-xl shadow-md'],
    props: ['title', 'description', 'image', 'footer']
  },
  
  modals: {
    filenames: ['modal', 'dialog', 'overlay', 'drawer', 'sheet', 'confirm-dialog'],
    classPatterns: ['modal', 'fixed inset-0 z-50 flex items-center justify-center', 'bg-black/50'],
    props: ['isOpen', 'onClose', 'title', 'children']
  },
  
  tables: {
    filenames: ['table', 'data-table', 'grid', 'list', 'data-grid'],
    classPatterns: ['table', 'w-full text-left border-collapse', 'divide-y divide-gray-200'],
    props: ['data', 'columns', 'sortable', 'pagination']
  },
  
  navigation: {
    filenames: ['nav', 'navbar', 'sidebar', 'menu', 'breadcrumb', 'pagination', 'tabs'],
    classPatterns: ['nav', 'flex items-center space-x-4', 'fixed top-0 w-full'],
    props: ['items', 'activeItem', 'onNavigate']
  },
  
  alerts: {
    filenames: ['alert', 'toast', 'notification', 'banner', 'message', 'snackbar'],
    classPatterns: ['alert', 'rounded-md p-4', 'flex items-start gap-3'],
    props: ['type', 'message', 'onClose', 'duration']
  },
  
  badges: {
    filenames: ['badge', 'tag', 'pill', 'status-badge', 'label'],
    classPatterns: ['badge', 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium'],
    props: ['variant', 'children']
  },
  
  avatars: {
    filenames: ['avatar', 'user-avatar', 'profile-image', 'initials', 'user-pic'],
    classPatterns: ['avatar', 'w-10 h-10 rounded-full', 'inline-block relative'],
    props: ['src', 'alt', 'size', 'fallback']
  },
  
  tooltips: {
    filenames: ['tooltip', 'popover', 'hint', 'help-text', 'info-bubble'],
    classPatterns: ['tooltip', 'absolute z-10 px-2 py-1 text-sm rounded shadow-lg'],
    props: ['content', 'children', 'position']
  }
};
```

## Token Coverage Analysis

### Calculate Token Usage
```javascript
function analyzeTokenCoverage(usedClasses, theme) {
  const coverage = {
    colors: { total: 0, used: 0, unused: [] },
    spacing: { total: 0, used: 0, unused: [] },
    fonts: { total: 0, used: 0, unused: [] },
    radius: { total: 0, used: 0, unused: [] }
  };
  
  // Colors
  coverage.colors.total = Object.keys(theme.colors).length;
  for (const [colorName] of Object.entries(theme.colors)) {
    const isUsed = usedClasses.some(cls => 
      cls.includes(`bg-${colorName}`) ||
      cls.includes(`text-${colorName}`) ||
      cls.includes(`border-${colorName}`) ||
      cls.includes(`from-${colorName}`) ||
      cls.includes(`to-${colorName}`)
    );
    if (isUsed) coverage.colors.used++;
    else coverage.colors.unused.push(colorName);
  }
  
  // Spacing
  coverage.spacing.total = Object.keys(theme.spacing).length;
  for (const [spacingName] of Object.entries(theme.spacing)) {
    const isUsed = usedClasses.some(cls =>
      cls.includes(`p-${spacingName}`) ||
      cls.includes(`m-${spacingName}`) ||
      cls.includes(`gap-${spacingName}`) ||
      cls.includes(`w-${spacingName}`) ||
      cls.includes(`h-${spacingName}`)
    );
    if (isUsed) coverage.spacing.used++;
    else coverage.spacing.unused.push(spacingName);
  }
  
  // Calculate percentages
  for (const category of Object.keys(coverage)) {
    const cat = coverage[category];
    cat.percentage = cat.total > 0 ? Math.round((cat.used / cat.total) * 100) : 0;
  }
  
  return coverage;
}
```

## Anti-Patterns Detection

### Common Issues to Flag
```javascript
const antiPatterns = {
  // Using arbitrary values instead of theme tokens
  arbitraryInsteadOfToken: {
    pattern: /\b(bg|text|border)-\[(#[0-9a-fA-F]{3,8})\]/g,
    message: 'Using hardcoded color instead of theme token',
    severity: 'warning'
  },
  
  // Excessive arbitrary values
  excessiveArbitrary: {
    threshold: 20,
    message: 'High number of arbitrary values detected - consider adding to theme',
    severity: 'suggestion'
  },
  
  // Missing responsive prefixes
  missingResponsive: {
    check: (classes) => {
      const hasMobile = classes.some(c => /^(sm|md|lg|xl):/.test(c));
      const totalLayout = classes.filter(c => /^(flex|grid|block|w-|h-)/.test(c)).length;
      return totalLayout > 5 && !hasMobile;
    },
    message: 'Layout classes without responsive variants',
    severity: 'suggestion'
  },
  
  // Important modifier abuse
  importantAbuse: {
    threshold: 10,
    pattern: /\![a-z-]+/g,
    message: 'Excessive use of !important modifier',
    severity: 'warning'
  }
};
```

## Output Schema (Enhanced)

```json
{
  "detected": true,
  "version": "3.3.0",
  "majorVersion": 3,
  "configType": "js-config",
  
  "theme": {
    "colors": { "primary": "#3b82f6", "secondary": "#1d4ed8" },
    "fonts": { "sans": "Inter, system-ui" },
    "spacing": {},
    "borderRadius": {},
    "shadows": {},
    "breakpoints": {}
  },
  
  "frameworks": [
    {
      "name": "shadcn/ui",
      "type": "component-library",
      "confidence": "high",
      "detectedBy": "folder-structure"
    }
  ],
  
  "usage": {
    "stats": {
      "totalFiles": 50,
      "filesWithTailwind": 45,
      "totalClasses": 2500,
      "uniqueClasses": 180,
      "tokenCoverage": 75
    },
    "topClasses": [
      { "name": "flex", "count": 120 },
      { "name": "p-4", "count": 95 },
      { "name": "text-center", "count": 80 }
    ],
    "arbitraryValues": [
      { "class": "w-[123px]", "file": "src/components/card.tsx" }
    ],
    "responsivePrefixes": {
      "sm": 150,
      "md": 80,
      "lg": 40
    },
    "hardcodedValues": [
      { "value": "bg-[#1da1f2]", "file": "src/components/button.tsx" }
    ]
  },
  
  "baseComponents": {
    "buttons": [
      { "name": "button", "file": "src/components/ui/button.tsx", "detectedBy": "filename" }
    ],
    "inputs": [
      { "name": "input", "file": "src/components/ui/input.tsx", "detectedBy": "filename" }
    ],
    "total": 15
  },
  
  "customizations": {
    "type": "moderate",
    "count": 15,
    "hasBrandColors": true,
    "hasCustomFonts": true
  }
}
```

## Health Score Calculation

```javascript
function calculateHealthScore(result) {
  let score = 100;
  
  // Deductions
  if (result.customizations.type === 'default') score -= 10; // No custom theme
  if (result.usage.hardcodedValues.length > 10) score -= 15; // Hardcoded colors
  if (result.usage.stats.tokenCoverage < 50) score -= 20; // Poor token usage
  if (result.usage.arbitraryValues.length > 30) score -= 10; // Too many arbitrary
  if (!result.darkMode) score -= 5; // No dark mode config
  if (result.plugins.length === 0) score -= 5; // No plugins
  if (result.errors.length > 0) score -= 10; // Config errors
  
  // Bonuses
  if (result.customizations.type === 'moderate') score += 5;
  if (result.customizations.type === 'heavy') score += 10;
  if (result.usage.stats.tokenCoverage > 80) score += 5;
  if (result.frameworks.length > 0) score += 5;
  if (result.baseComponents.total > 10) score += 5;
  
  return Math.max(0, Math.min(100, score));
}
```

| Score | Rating | Description |
|-------|--------|-------------|
| 90-100 | Excellent | Production-ready, well-configured |
| 70-89 | Good | Solid setup, minor improvements possible |
| 50-69 | Fair | Functional but needs optimization |
| 30-49 | Poor | Significant issues need addressing |
| 0-29 | Critical | Requires immediate attention |
