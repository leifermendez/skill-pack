# FAANG Design System Detection Patterns

## Resumen de Investigación

Basado en análisis de blogs de ingeniería, repositorios públicos y documentación oficial de las principales empresas tecnológicas.

## Meta (Facebook) - StyleX

### Arquitectura CSS
- **Sistema**: StyleX (CSS-in-JS compilado a CSS atómico)
- **Reducción**: 80% de CSS en homepage (de 400KB a <80KB comprimido)
- **Crecimiento**: Logarítmico (proporcional a declaraciones únicas, no features)
- **Co-locación**: Estilos junto a componentes, separados en build time

### Detección de Patrones
```javascript
// StyleX source code
const styles = stylex.create({
  emphasis: { fontWeight: 'bold' },
  text: { fontSize: '16px', fontWeight: 'normal' }
});

// Generated CSS (atomic)
.c0 { font-weight: bold; }
.c1 { font-weight: normal; }
.c2 { font-size: 0.9rem; }

// Generated JS
function MyComponent(props) {
  return <span className={(props.isEmphasized ? 'c0 ' : 'c1 ') + 'c2 '} />;
}
```

### Tokens y Theming
- CSS variables para temas (dark mode)
- Variables definidas bajo clases aplicadas a DOM elements
- Build tool convierte px a rem automáticamente
- Soporte para fuentes dinámicas y accesibilidad

### Scripts de Detección Específicos
```javascript
// Detectar StyleX
const hasStyleX = packageJson.dependencies?.['@stylexjs/stylex'] || 
                  packageJson.devDependencies?.['@stylexjs/stylex'];

// Detectar uso de stylex.create
const stylexMatches = content.match(/stylex\.create\s*\(/g);

// Detectar stylex.props
const propsMatches = content.match(/stylex\.props\s*\(/g);

// Detectar stylex.defineVars (tokens)
const varsMatches = content.match(/stylex\.defineVars\s*\(/g);
```

## Google - Material Design

### Arquitectura CSS
- **Sistema**: Material Design Components (MDC Web)
- **Lenguajes**: TypeScript (53.5%), SCSS (45.2%), JavaScript (1.2%)
- **Enfoque**: Modular y customizable
- **Theming**: Flexible customization de color, typography, shape, states

### Estructura de Componentes
```
packages/
  mdc-button/
    ├── component.ts
    ├── foundation.ts
    ├── adapter.ts
    ├── styles.scss
    └── README.md
```

### Detección de Patrones
- Clases prefijadas: `.mdc-*`, `.mat-*` (Angular Material)
- SCSS con `@use` y `@include`
- Theming mixins: `@include button.core-styles;`
- Custom properties: `--mdc-theme-primary`, `--mdc-theme-secondary`

### Tokens y Variables
```scss
// Material Design Tokens
:root {
  --mdc-theme-primary: #6200ee;
  --mdc-theme-secondary: #03dac6;
  --mdc-theme-background: #fff;
  --mdc-theme-surface: #fff;
  --mdc-theme-error: #b00020;
}
```

### Scripts de Detección
```javascript
// Detectar Material Design
const materialPackages = [
  '@material/button',
  '@material/textfield',
  '@material/checkbox',
  '@material/radio',
  '@angular/material'
];

// Detectar clases MDC
const mdcClassPattern = /\.mdc-[a-z]+/g;

// Detectar variables de tema
const themeVars = content.match(/--mdc-theme-[\w-]+/g);
```

## Amazon - Style Dictionary

### Arquitectura de Tokens
- **Sistema**: Style Dictionary (cross-platform)
- **Formato**: JSON para definición de tokens
- **Output**: Múltiples plataformas (iOS, Android, CSS, JS, SCSS)
- **Estructura**: CTI (Category/Type/Item)

### Estructura de Tokens
```json
{
  "color": {
    "background": {
      "primary": { "value": "#ffffff" },
      "secondary": { "value": "#f5f5f5" }
    },
    "text": {
      "primary": { "value": "#212121" },
      "secondary": { "value": "#757575" }
    }
  },
  "size": {
    "font": {
      "small": { "value": "12px" },
      "medium": { "value": "16px" },
      "large": { "value": "20px" }
    }
  }
}
```

### Configuración de Build
```json
{
  "source": ["tokens/**/*.json"],
  "platforms": {
    "scss": {
      "transformGroup": "scss",
      "buildPath": "build/",
      "files": [{
        "destination": "variables.scss",
        "format": "scss/variables"
      }]
    },
    "css": {
      "transformGroup": "css",
      "buildPath": "build/css/",
      "files": [{
        "destination": "variables.css",
        "format": "css/variables"
      }]
    }
  }
}
```

### Scripts de Detección
```javascript
// Detectar Style Dictionary
const hasStyleDictionary = packageJson.devDependencies?.['style-dictionary'];

// Detectar tokens JSON
const tokenFiles = glob.sync('tokens/**/*.json');

// Detectar config de Style Dictionary
const configFiles = ['config.json', 'config.js', 'sd.config.js'];

// Detectar referencias de tokens
const tokenRefs = content.match(/\{[\w.]+\}/g); // {color.primary.value}
```

## Airbnb - Lunar

### Arquitectura CSS
- **Sistema**: Lunar Design System
- **Stack**: TypeScript (97.9%), React
- **Enfoque**: Toolkit open source e interno
- **Organización**: Monorepo con Lerna

### Estructura de Componentes
```
packages/
  core/
    ├── Button/
    │   ├── index.tsx
    │   ├── styles.ts
    │   └── types.ts
    ├── Input/
    ├── Select/
    └── TextArea/
  themes/
    ├── light.ts
    └── dark.ts
```

### Detección de Patrones
- Componentes con co-located styles
- Themes separados del core
- Uso de TypeScript interfaces para props
- Nomenclatura consistente: `Button`, `Input`, `TextArea`

## Netflix

### Arquitectura (Basado en publicaciones técnicas)
- **Sistema**: Custom design system
- **Enfoque**: Atomic Design para UI consistente
- **Escalabilidad**: API con GraphQL federation
- **Performance**: Lazy loading y code splitting

### Patrones Detectados
```javascript
// Componentes atómicos
atoms/     // Button, Input, Label
molecules/ // FormField, SearchBar
organisms/ // Header, Hero, Footer
templates/ // Layouts
pages/     // Route components
```

## Apple

### Arquitectura (Basado en documentación pública)
- **Sistema**: Human Interface Guidelines
- **Enfoque**: Design tokens para iOS/macOS
- **Formatos**: asset catalogs, storyboards
- **Detección**: Archivos `.xcassets`, `.storyboard`

## Patrones Comunes en FAANG

### 1. Atomic CSS
Todas las empresas utilizan o están migrando a CSS atómico:
- **Meta**: StyleX (compilado a CSS atómico)
- **Google**: Material Design utilidades
- **Amazon**: Style Dictionary genera utilidades
- **Airbnb**: Lunar usa styled-components pero con optimización

### 2. Design Tokens
Estandarización de tokens cross-platform:
- **Formato**: JSON primero (Amazon Style Dictionary)
- **Output**: CSS variables, SCSS, JS constants
- **Nomenclatura**: CTI (Category/Type/Item)
- **Aliases**: `{size.font.medium}` referencia otro token

### 3. Co-locación de Estilos
Patrón universal:
```
ComponentName/
  ├── index.tsx
  ├── styles.css|scss|ts
  ├── types.ts
  └── test.tsx
```

### 4. Theming con CSS Variables
Meta y Google usan CSS custom properties:
```css
.light-theme {
  --card-bg: #eee;
  --text-primary: #212121;
}
.dark-theme {
  --card-bg: #111;
  --text-primary: #ffffff;
}
```

### 5. Build-Time Optimization
Todas compilan/transforman en build time:
- Meta: StyleX compila a CSS atómico
- Google: SCSS compila a CSS
- Amazon: Style Dictionary genera múltiples formatos
- Airbnb: TypeScript compila con Babel

## Matriz de Detección FAANG

| Empresa | Framework | Arquitectura | Tokens | Base Components |
|---------|-----------|--------------|---------|-----------------|
| Meta | StyleX | Atomic CSS | stylex.defineVars | Button, Input, Label |
| Google | Material | SCSS + CSS | --mdc-theme-* | Button, TextField, Checkbox |
| Amazon | Custom | JSON → CSS/SCSS | Style Dictionary | Button, Input, Select |
| Netflix | Custom | Atomic Design | CSS Variables | Button, Input, TextArea |
| Airbnb | Lunar | TypeScript | Theme objects | Button, Input, TextArea |
| Apple | HIG | Asset Catalogs | .xcassets | UIButton, UITextField |

## Algoritmos de Detección Optimizados

### 1. Detección de Atomic CSS
```javascript
function detectAtomicCSS(files) {
  const atomicPatterns = [
    /\.[a-z]\d+\s*\{/g,                    // .c0 { }
    /stylex\.create\s*\(/g,                 // stylex.create()
    /tailwindcss/g,                          // tailwind
    /\.([a-z]+-\d+|flex|grid|block)\s*\{/g  // utilidades
  ];
  
  return atomicPatterns.some(pattern => 
    files.some(file => pattern.test(file.content))
  );
}
```

### 2. Detección de Design Tokens
```javascript
function detectDesignTokens(projectPath) {
  const indicators = {
    styleDictionary: fs.existsSync('config.json') || 
                     fs.existsSync('sd.config.js'),
    tokensFolder: fs.existsSync('tokens/'),
    cssVariables: searchFilesForPattern('--[\w-]+\s*:'),
    stylexVars: searchFilesForPattern('stylex\.defineVars'),
    mdcVars: searchFilesForPattern('--mdc-theme-')
  };
  
  return indicators;
}
```

### 3. Detección de Arquitectura
```javascript
function detectArchitecture(projectPath) {
  const scores = {
    atomic: checkFolders(['atoms', 'molecules', 'organisms']),
    bem: checkNamingPattern('__', '--'),
    material: checkFiles(['mdc-', 'mat-']),
    stylex: checkDependencies(['@stylexjs/stylex']),
    tailwind: checkFiles(['tailwind.config'])
  };
  
  return Object.entries(scores)
    .sort((a, b) => b[1] - a[1])
    .map(([name, score]) => ({ name, score }));
}
```

## Recomendaciones para el Scanner

### 1. Prioridad de Detección
1. **Meta/StyleX**: Detectar `stylex.create`, `@stylexjs/stylex`
2. **Google/Material**: Detectar `.mdc-*`, `@material/*`
3. **Amazon/Tokens**: Detectar `style-dictionary`, `tokens/**/*.json`
4. **Tailwind**: Detectar `tailwind.config.*`, `@tailwind`
5. **BEM/Atomic**: Detectar patrones de nomenclatura y carpetas

### 2. Estrategia de Scanning
- **Fase 1**: `package.json` (dependencias rápidas)
- **Fase 2**: Config files (tailwind.config, sd.config)
- **Fase 3**: Estructura de carpetas (atoms/, molecules/)
- **Fase 4**: Contenido de archivos (regex patterns)
- **Fase 5**: AST parsing para componentes complejos

### 3. Outputs Normalizados
Independientemente del framework, generar:
```json
{
  "framework": "stylex|material|tailwind|bem|atomic",
  "tokens": {
    "colors": [],
    "fonts": [],
    "spacing": [],
    "borderRadius": []
  },
  "components": {
    "atoms": [],
    "molecules": [],
    "organisms": []
  },
  "architecture": {
    "primary": "atomic",
    "confidence": 95
  }
}
```

## Referencias

- Meta StyleX: https://stylexjs.com/
- Material Design: https://m3.material.io/
- Style Dictionary: https://amzn.github.io/style-dictionary/
- Airbnb Lunar: https://github.com/airbnb/lunar
- Meta Engineering: https://engineering.fb.com/2020/05/08/web/facebook-redesign/
