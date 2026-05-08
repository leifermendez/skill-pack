# Anti-Pattern: Magic Numbers

> Valores numéricos hardcodeados sin contexto ni sistema de diseño.

## El Problema

```css
/* ❌ PROHIBIDO */
.card {
  margin-top: 37px;    /* ¿por qué 37? */
  width: 243px;        /* ¿por qué 243? */
  padding: 14px 23px;  /* ¿de dónde salen estos? */
  border-radius: 7px;   /* ¿por qué no 8? */
}
```

### Impacto
- **Inconsistencia visual**: 37px aquí, 38px allá. El diseño se ve "desajustado".
- **Imposible de escalar**: ¿Quieres duplicar el spacing? Editas 200 valores.
- **No documentado**: Nadie sabe por qué es ese número.
- **Breakpoints fantasmas**: `max-width: 767px` porque "así se veía bien".

---

## Causa Raíz
- Diseñador entregó mockups en px y el dev copió literalmente.
- No hay sistema de diseño / design tokens.
- Copy-paste de Chrome DevTools sin pensar.
- Fix rápido que nunca se refactorizó.

---

## Fix

### 1. Custom Properties (CSS Variables)
```css
:root {
  --space-1: 0.25rem;   /* 4px  */
  --space-2: 0.5rem;    /* 8px  */
  --space-3: 0.75rem;   /* 12px */
  --space-4: 1rem;      /* 16px */
  --space-6: 1.5rem;    /* 24px */
  --space-8: 2rem;      /* 32px */
}

.card {
  margin-top: var(--space-6);
  padding: var(--space-3) var(--space-4);
}
```

### 2. Sistema de 8pt Grid
```css
:root {
  --space-base: 8px;
  --space-1: calc(var(--space-base) * 0.5);   /* 4px  */
  --space-2: var(--space-base);                 /* 8px  */
  --space-3: calc(var(--space-base) * 1.5);    /* 12px */
  --space-4: calc(var(--space-base) * 2);      /* 16px */
  --space-6: calc(var(--space-base) * 3);      /* 24px */
  --space-8: calc(var(--space-base) * 4);      /* 32px */
}
```

### 3. Breakpoints documentados
```css
:root {
  --bp-sm: 640px;
  --bp-md: 768px;
  --bp-lg: 1024px;
  --bp-xl: 1280px;
}

@media (min-width: var(--bp-md)) {
  .card { padding: var(--space-6); }
}
```

---

## Regla
> **Cualquier número > 10 en CSS debe justificarse.** Si no tiene razón de ser en tu sistema de diseño, es un magic number.
