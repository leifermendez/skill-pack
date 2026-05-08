# Pattern: Navbar (BEM)

> Navegación responsive con menú hamburguesa, dropdowns accesibles y skip link.

## HTML

```html
<!-- Skip Link (accesibilidad) -->
<a class="skip-link" href="#main-content">Saltar al contenido principal</a>

<header class="navbar">
  <div class="navbar__container">
    <a class="navbar__brand" href="/">
      <img class="navbar__logo" src="logo.svg" alt="MiApp" />
    </a>

    <button class="navbar__toggle btn btn--ghost btn--icon-only" aria-expanded="false" aria-controls="navbar-menu" aria-label="Abrir menú de navegación">
      <span class="btn__icon" aria-hidden="true">
        <svg class="navbar__icon-menu">...</svg>
        <svg class="navbar__icon-close">...</svg>
      </span>
    </button>

    <nav class="navbar__nav" id="navbar-menu" aria-label="Navegación principal">
      <ul class="navbar__list">
        <li class="navbar__item">
          <a class="navbar__link navbar__link--active" href="/" aria-current="page">Inicio</a>
        </li>
        <li class="navbar__item">
          <a class="navbar__link" href="/products">Productos</a>
        </li>
        <li class="navbar__item navbar__item--has-dropdown">
          <button class="navbar__link navbar__link--toggle" aria-expanded="false" aria-controls="dropdown-services">
            Servicios
            <span class="navbar__caret" aria-hidden="true"></span>
          </button>
          <ul class="navbar__dropdown" id="dropdown-services">
            <li><a class="navbar__dropdown-link" href="/consulting">Consultoría</a></li>
            <li><a class="navbar__dropdown-link" href="/support">Soporte</a></li>
          </ul>
        </li>
        <li class="navbar__item">
          <a class="navbar__link" href="/contact">Contacto</a>
        </li>
      </ul>
    </nav>

    <div class="navbar__actions">
      <a class="btn btn--ghost" href="/login">Iniciar sesión</a>
      <a class="btn btn--primary" href="/signup">Registrarse</a>
    </div>
  </div>
</header>

<main id="main-content" tabindex="-1">
  <!-- Contenido -->
</main>
```

## CSS

```css
/* === Skip Link === */
.skip-link {
  background: var(--color-primary);
  color: var(--color-on-primary);
  font-weight: 500;
  left: var(--space-4);
  padding: var(--space-2) var(--space-4);
  position: absolute;
  top: calc(var(--space-4) * -1);
  transition: top 0.2s ease;
  z-index: var(--z-skip-link);
}

.skip-link:focus-visible {
  outline: none;
  top: var(--space-4);
}

/* === Block === */
.navbar {
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  position: relative;
}

.navbar__container {
  align-items: center;
  display: flex;
  gap: var(--space-4);
  margin: 0 auto;
  max-width: var(--container-max);
  padding: var(--space-3) var(--space-4);
}

/* === Brand === */
.navbar__brand {
  display: inline-flex;
  flex-shrink: 0;
  margin-right: auto;
}

.navbar__logo {
  display: block;
  height: 2rem;
  width: auto;
}

/* === Toggle (mobile) === */
.navbar__toggle {
  display: none;
}

.navbar__icon-close {
  display: none;
}

.navbar__toggle[aria-expanded="true"] .navbar__icon-menu {
  display: none;
}

.navbar__toggle[aria-expanded="true"] .navbar__icon-close {
  display: block;
}

/* === Nav === */
.navbar__nav {
  align-items: center;
  display: flex;
  flex: 1;
  gap: var(--space-4);
}

.navbar__list {
  align-items: center;
  display: flex;
  gap: var(--space-1);
  list-style: none;
  margin: 0;
  padding: 0;
}

.navbar__item {
  position: relative;
}

.navbar__link {
  align-items: center;
  border-radius: var(--radius-sm);
  color: var(--color-text);
  display: inline-flex;
  font-weight: 500;
  gap: var(--space-1);
  padding: var(--space-2) var(--space-3);
  text-decoration: none;
  transition: background-color 0.2s ease, color 0.2s ease;
}

.navbar__link:hover {
  background: var(--color-surface-hover);
  color: var(--color-primary);
}

.navbar__link:focus-visible {
  box-shadow: 0 0 0 2px var(--color-focus);
  outline: none;
}

.navbar__link--active {
  color: var(--color-primary);
}

.navbar__link--toggle {
  background: none;
  border: 0;
  cursor: pointer;
  font-family: inherit;
  font-size: inherit;
}

.navbar__caret {
  border-color: currentColor transparent transparent;
  border-style: solid;
  border-width: 4px 4px 0;
  display: inline-block;
  transition: transform 0.2s ease;
}

[aria-expanded="true"] .navbar__caret {
  transform: rotate(180deg);
}

/* === Dropdown === */
.navbar__dropdown {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-lg);
  display: none;
  left: 0;
  list-style: none;
  margin: 0;
  min-width: 12rem;
  padding: var(--space-2);
  position: absolute;
  top: calc(100% + var(--space-1));
  z-index: var(--z-dropdown);
}

.navbar__item--has-dropdown:hover .navbar__dropdown,
.navbar__link--toggle[aria-expanded="true"] ~ .navbar__dropdown {
  display: block;
}

.navbar__dropdown-link {
  border-radius: var(--radius-sm);
  color: var(--color-text);
  display: block;
  padding: var(--space-2) var(--space-3);
  text-decoration: none;
  transition: background-color 0.2s ease;
}

.navbar__dropdown-link:hover {
  background: var(--color-surface-hover);
}

/* === Actions === */
.navbar__actions {
  align-items: center;
  display: flex;
  gap: var(--space-3);
  margin-left: auto;
}

/* === Responsive === */
@media (max-width: 768px) {
  .navbar__toggle {
    display: inline-flex;
  }

  .navbar__nav {
    background: var(--color-surface);
    border-bottom: 1px solid var(--color-border);
    display: none;
    flex-direction: column;
    inset: 100% 0 auto;
    padding: var(--space-4);
    position: absolute;
  }

  .navbar__nav.is-open {
    display: flex;
  }

  .navbar__list {
    flex-direction: column;
    width: 100%;
  }

  .navbar__item--has-dropdown .navbar__dropdown {
    border: 0;
    box-shadow: none;
    display: none;
    position: static;
  }

  .navbar__item--has-dropdown .navbar__dropdown.is-open {
    display: block;
  }

  .navbar__actions {
    display: none;
  }
}
```

## Tokens Requeridos

```css
:root {
  --color-surface: #ffffff;
  --color-surface-hover: #f8fafc;
  --color-border: #e2e8f0;
  --color-text: #1e293b;
  --color-primary: #2563eb;
  --color-on-primary: #ffffff;
  --color-focus: #bfdbfe;

  --container-max: 80rem;

  --font-size-base: 1rem;

  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;

  --radius-sm: 4px;
  --radius-md: 8px;

  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);

  --z-skip-link: 60;
  --z-dropdown: 50;
}
```

## Checklist

- [ ] Skip link visible solo al tabular (`:focus-visible`)
- [ ] `aria-expanded` + `aria-controls` en toggle y dropdowns
- [ ] `aria-current="page"` en link activo
- [ ] `aria-label` en icon-only buttons
- [ ] Nav colapsa en mobile con `.is-open` controlada por JS
- [ ] Dropdowns usan hover en desktop, click en mobile
- [ ] No nesting CSS: cada selector es plano
- [ ] `navbar__actions` se oculta en mobile (o se mueve al menú)
- [ ] `z-index` tokenizado (`--z-skip-link`, `--z-dropdown`)
