# Pattern: Design Tokens (CSS Custom Properties)

> Sistema completo de tokens de diseño para cualquier proyecto CSS.

## Estructura de Tokens

```css
/* === 1. Colors === */
:root {
  /* Primarios */
  --color-primary: #2563eb;
  --color-primary-hover: #1d4ed8;
  --color-primary-subtle: #eff6ff;
  --color-on-primary: #ffffff;

  /* Superficies */
  --color-surface: #ffffff;
  --color-surface-hover: #f8fafc;
  --color-surface-raised: #ffffff;
  --color-surface-sunken: #f1f5f9;

  /* Texto */
  --color-text: #1e293b;
  --color-text-secondary: #475569;
  --color-text-muted: #64748b;
  --color-text-placeholder: #94a3b8;
  --color-text-on-primary: #ffffff;

  /* Bordes */
  --color-border: #e2e8f0;
  --color-border-hover: #cbd5e1;
  --color-divider: #f1f5f9;

  /* Semánticos */
  --color-success: #16a34a;
  --color-success-subtle: #f0fdf4;
  --color-warning: #ca8a04;
  --color-warning-subtle: #fefce8;
  --color-danger: #dc2626;
  --color-danger-subtle: #fef2f2;
  --color-info: #0284c7;
  --color-info-subtle: #f0f9ff;

  /* Focus */
  --color-focus: #bfdbfe;
  --color-focus-danger: #fecaca;
}

/* === 2. Spacing (8pt Grid) === */
:root {
  --space-base: 0.25rem; /* 4px */

  --space-0: 0;
  --space-1: var(--space-base);          /* 4px */
  --space-2: calc(var(--space-base) * 2);   /* 8px */
  --space-3: calc(var(--space-base) * 3);  /* 12px */
  --space-4: calc(var(--space-base) * 4);  /* 16px */
  --space-5: calc(var(--space-base) * 5);  /* 20px */
  --space-6: calc(var(--space-base) * 6);  /* 24px */
  --space-8: calc(var(--space-base) * 8);  /* 32px */
  --space-10: calc(var(--space-base) * 10); /* 40px */
  --space-12: calc(var(--space-base) * 12); /* 48px */
  --space-16: calc(var(--space-base) * 16); /* 64px */
  --space-20: calc(var(--space-base) * 20); /* 80px */
  --space-24: calc(var(--space-base) * 24); /* 96px */
}

/* === 3. Typography === */
:root {
  --font-sans: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;

  --font-size-xs: 0.75rem;    /* 12px */
  --font-size-sm: 0.875rem;   /* 14px */
  --font-size-base: 1rem;     /* 16px */
  --font-size-lg: 1.125rem;   /* 18px */
  --font-size-xl: 1.25rem;    /* 20px */
  --font-size-2xl: 1.5rem;    /* 24px */
  --font-size-3xl: 1.875rem;  /* 30px */
  --font-size-4xl: 2.25rem;   /* 36px */

  --line-height-tight: 1.25;
  --line-height-snug: 1.375;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.625;
  --line-height-loose: 2;

  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
}

/* === 4. Border Radius === */
:root {
  --radius-none: 0;
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-2xl: 24px;
  --radius-full: 9999px;
}

/* === 5. Shadows === */
:root {
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
  --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
  --shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

/* === 6. Z-Index === */
:root {
  --z-base: 0;
  --z-dropdown: 10;
  --z-sticky: 20;
  --z-fixed: 30;
  --z-overlay: 40;
  --z-modal: 50;
  --z-toast: 60;
  --z-tooltip: 70;
  --z-skip-link: 80;
}

/* === 7. Breakpoints (referencia, no para media queries directas) === */
:root {
  --bp-sm: 640px;
  --bp-md: 768px;
  --bp-lg: 1024px;
  --bp-xl: 1280px;
  --bp-2xl: 1536px;
}

/* === 8. Container === */
:root {
  --container-sm: 640px;
  --container-md: 768px;
  --container-lg: 1024px;
  --container-xl: 1280px;
  --container-max: 80rem;
}

/* === 9. Transitions === */
:root {
  --duration-instant: 0ms;
  --duration-fast: 150ms;
  --duration-normal: 200ms;
  --duration-slow: 300ms;
  --duration-slower: 500ms;

  --ease-linear: linear;
  --ease-in: cubic-bezier(0.4, 0, 1, 1);
  --ease-out: cubic-bezier(0, 0, 0.2, 1);
  --ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
}
```

## Uso

```css
.btn--primary {
  background: var(--color-primary);
  color: var(--color-on-primary);
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  font-family: var(--font-sans);
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-medium);
  transition: background-color var(--duration-normal) var(--ease-out);
}
```

## Dark Theme (ejemplo)

```css
[data-theme="dark"] {
  --color-surface: #0f172a;
  --color-surface-hover: #1e293b;
  --color-text: #f8fafc;
  --color-text-secondary: #cbd5e1;
  --color-text-muted: #94a3b8;
  --color-border: #334155;
  --color-border-hover: #475569;
}
```

## Reglas

- [ ] Todos los valores mágicos deben venir de tokens
- [ ] Usar `rem` para spacing y typography (accesibilidad)
- [ ] Usar `px` solo para border-width y border-radius (evita antialiasing raro)
- [ ] Z-index tokenizado, nunca números mágicos
- [ ] Breakpoints en custom properties para referencia (aunque no se puedan usar directamente en `@media`)
- [ ] Transiciones con tokens de duration y easing
