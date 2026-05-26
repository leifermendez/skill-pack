#!/usr/bin/env node
/**
 * Ultra-Precise Tailwind CSS Detection Script
 * Detects Tailwind v2, v3, v4 with full theme extraction
 * Usage: node detect-tailwind.js <project-path>
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

class TailwindDetector {
  constructor(projectPath) {
    this.projectPath = projectPath;
    this.result = {
      detected: false,
      version: null,
      majorVersion: null,
      configType: null, // 'js-config' | 'css-config' | 'unknown'
      configPath: null,
      config: {},
      plugins: [],
      theme: {
        colors: {},
        fonts: {},
        fontSizes: {},
        spacing: {},
        borderRadius: {},
        shadows: {},
        breakpoints: {},
        zIndex: {},
        animation: {},
        extend: {}
      },
      customizations: {},
      contentPaths: [],
      prefix: null,
      corePlugins: {},
      darkMode: null,
      important: null,
      separator: null,
      safelist: [],
      presets: [],
      layerStrategy: 'standard', // 'standard' | 'css-layers'
      v4Features: {
        cssVariables: [],
        themeDirectives: [],
        importTailwindcss: false
      },
      frameworks: [],
      usage: {
        tailwindClasses: {},
        arbitraryValues: [],
        responsivePrefixes: {},
        darkModeClasses: [],
        customClasses: [],
        hardcodedValues: [],
        stats: {
          totalFiles: 0,
          filesWithTailwind: 0,
          totalClasses: 0,
          uniqueClasses: 0,
          tokenCoverage: 0
        },
        topClasses: []
      },
      baseComponents: {
        buttons: [],
        inputs: [],
        selects: [],
        textareas: [],
        labels: [],
        checkboxes: [],
        radios: [],
        switches: [],
        cards: [],
        modals: [],
        tables: [],
        navigation: [],
        tabs: [],
        alerts: [],
        badges: [],
        avatars: [],
        tooltips: [],
        total: 0
      },
      errors: [],
      confidence: 'high'
    };
  }

  detect() {
    try {
      this.detectViaPackageJson();
      this.detectConfig();
      this.detectEntryFiles();
      
      if (this.result.majorVersion === 4) {
        this.parseV4Config();
      } else if (this.result.majorVersion <= 3) {
        this.parseV3Config();
      }
      
      this.extractTheme();
      this.detectPlugins();
      this.analyzeCustomizations();
      
      // NEW ENHANCED FEATURES
      this.detectFrameworks();
      this.analyzeUsage();
      this.detectBaseComponents();
    } catch (error) {
      this.result.errors.push(error.message);
    }
    return this.result;
  }

  detectViaPackageJson() {
    const packageJsonPath = path.join(this.projectPath, 'package.json');
    if (!fs.existsSync(packageJsonPath)) {
      this.result.errors.push('No package.json found');
      return;
    }

    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
    const deps = {
      ...packageJson.dependencies,
      ...packageJson.devDependencies,
      ...packageJson.peerDependencies
    };

    // Detect Tailwind
    if (deps.tailwindcss) {
      this.result.detected = true;
      const version = deps.tailwindcss.replace(/^[\^~>=]/, '');
      this.result.version = version;
      this.result.majorVersion = parseInt(version.split('.')[0]) || 3;
    }

    // Check for v4 specific imports
    if (deps['@tailwindcss/postcss'] || deps['@tailwindcss/vite'] || deps['@tailwindcss/cli']) {
      this.result.detected = true;
      this.result.majorVersion = 4;
    }

    // Detect plugins
    const tailwindPlugins = [
      '@tailwindcss/forms',
      '@tailwindcss/typography',
      '@tailwindcss/aspect-ratio',
      '@tailwindcss/line-clamp',
      '@tailwindcss/container-queries',
      'tailwindcss-animate',
      'tailwind-scrollbar',
      'tailwind-merge',
      'clsx'
    ];

    for (const plugin of tailwindPlugins) {
      if (deps[plugin]) {
        this.result.plugins.push({
          name: plugin,
          version: deps[plugin].replace(/^[\^~>=]/, '')
        });
      }
    }

    // Detect PostCSS
    if (deps.postcss || deps['postcss-cli'] || deps['@tailwindcss/postcss']) {
      this.result.config.postcss = true;
    }
  }

  detectConfig() {
    // v3 config files
    const v3Configs = [
      'tailwind.config.js',
      'tailwind.config.ts',
      'tailwind.config.mjs',
      'tailwind.config.cjs',
      'tailwind.config.json'
    ];

    for (const config of v3Configs) {
      const configPath = path.join(this.projectPath, config);
      if (fs.existsSync(configPath)) {
        this.result.configPath = configPath;
        this.result.configType = 'js-config';
        return;
      }
    }

    // v4 CSS-based config
    const v4EntryFiles = [
      'src/index.css',
      'src/app.css',
      'src/styles.css',
      'app/globals.css',
      'styles/globals.css',
      'src/globals.css',
      'app.css',
      'index.css',
      'globals.css'
    ];

    for (const entry of v4EntryFiles) {
      const entryPath = path.join(this.projectPath, entry);
      if (fs.existsSync(entryPath)) {
        const content = fs.readFileSync(entryPath, 'utf-8');
        // v4 uses @import "tailwindcss" and @theme
        if (content.includes('@import "tailwindcss"') || 
            content.includes('@import "tailwindcss/') ||
            content.includes('@theme')) {
          this.result.configPath = entryPath;
          this.result.configType = 'css-config';
          this.result.majorVersion = 4;
          this.result.detected = true;
          return;
        }
      }
    }
  }

  detectEntryFiles() {
    const patterns = [
      'src/index.css',
      'src/styles.css',
      'src/app.css',
      'styles/globals.css',
      'app/globals.css',
      'app.css',
      'index.css',
      'globals.css',
      'src/assets/styles/main.css',
      'src/styles/main.css'
    ];

    this.result.entryFiles = [];
    for (const pattern of patterns) {
      const fullPath = path.join(this.projectPath, pattern);
      if (fs.existsSync(fullPath)) {
        const content = fs.readFileSync(fullPath, 'utf-8');
        // v3 directives
        if (content.includes('@tailwind') || content.includes('tailwindcss')) {
          this.result.entryFiles.push({
            path: fullPath,
            hasDirectives: content.includes('@tailwind base') || 
                          content.includes('@tailwind components') || 
                          content.includes('@tailwind utilities'),
            hasImports: content.includes('@import "tailwindcss"')
          });
        }
      }
    }
  }

  parseV3Config() {
    if (!this.result.configPath) return;

    const content = fs.readFileSync(this.result.configPath, 'utf-8');

    // Extract content/purge paths
    const contentMatch = content.match(/content\s*:\s*(?:\[|\()[^\]]*\]/s);
    if (contentMatch) {
      const paths = contentMatch[0].match(/['"`]([^'"`]+)['"`]/g);
      if (paths) {
        this.result.contentPaths = paths.map(p => p.replace(/['"`]/g, ''));
      }
    }

    // Extract dark mode
    const darkModeMatch = content.match(/darkMode\s*:\s*['"`]([^'"`]+)['"`]/);
    if (darkModeMatch) {
      this.result.darkMode = darkModeMatch[1];
    }

    // Extract prefix
    const prefixMatch = content.match(/prefix\s*:\s*['"`]([^'"`]+)['"`]/);
    if (prefixMatch) {
      this.result.prefix = prefixMatch[1];
    }

    // Extract important
    const importantMatch = content.match(/important\s*:\s*(true|false|['"`][^'"`]+['"`])/);
    if (importantMatch) {
      this.result.important = importantMatch[1];
    }

    // Extract separator
    const separatorMatch = content.match(/separator\s*:\s*['"`]([^'"`]+)['"`]/);
    if (separatorMatch) {
      this.result.separator = separatorMatch[1];
    }

    // Extract safelist
    const safelistMatch = content.match(/safelist\s*:\s*(?:\[|\()[^\]]*\]/s);
    if (safelistMatch) {
      const items = safelistMatch[0].match(/['"`]([^'"`]+)['"`]/g);
      if (items) {
        this.result.safelist = items.map(i => i.replace(/['"`]/g, ''));
      }
    }

    // Extract theme extend
    const extendMatch = content.match(/extend\s*:\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}/s);
    if (extendMatch) {
      this.parseThemeObject(extendMatch[0], 'extend');
    }

    // Extract corePlugins
    const corePluginsMatch = content.match(/corePlugins\s*:\s*\{([^}]+)\}/s);
    if (corePluginsMatch) {
      const lines = corePluginsMatch[1].split(',');
      for (const line of lines) {
        const match = line.match(/(\w+)\s*:\s*(true|false)/);
        if (match) {
          this.result.corePlugins[match[1]] = match[2] === 'true';
        }
      }
    }

    // Extract presets
    const presetsMatch = content.match(/presets\s*:\s*(?:\[|\()[^\]]*\]/s);
    if (presetsMatch) {
      const presetPaths = presetsMatch[0].match(/['"`]([^'"`]+)['"`]/g);
      if (presetPaths) {
        this.result.presets = presetPaths.map(p => p.replace(/['"`]/g, ''));
      }
    }
  }

  parseV4Config() {
    if (!this.result.configPath) return;

    const content = fs.readFileSync(this.result.configPath, 'utf-8');

    // Detect @theme directives
    const themeMatches = content.match(/@theme\s*\{([^}]*)\}/gs);
    if (themeMatches) {
      this.result.v4Features.themeDirectives = themeMatches;
      
      // Extract CSS variables from @theme
      for (const theme of themeMatches) {
        const varMatches = theme.match(/--[\w-]+\s*:\s*[^;]+/g);
        if (varMatches) {
          for (const v of varMatches) {
            const [name, value] = v.split(':').map(s => s.trim());
            this.result.v4Features.cssVariables.push({
              name,
              value: value.replace(';', '')
            });
          }
        }
      }
    }

    // Detect @import tailwindcss
    if (content.includes('@import "tailwindcss"') || 
        content.includes("@import 'tailwindcss'") ||
        content.includes('@import "tailwindcss/')) {
      this.result.v4Features.importTailwindcss = true;
    }

    // Detect CSS layers
    if (content.includes('@layer theme') || content.includes('@layer base')) {
      this.result.layerStrategy = 'css-layers';
    }

    // Extract custom theme variables
    this.extractV4ThemeVariables(content);
  }

  extractV4ThemeVariables(content) {
    // Namespace extraction
    const namespaces = {
      '--color-': 'colors',
      '--font-': 'fonts',
      '--text-': 'fontSizes',
      '--spacing-': 'spacing',
      '--radius-': 'borderRadius',
      '--shadow-': 'shadows',
      '--breakpoint-': 'breakpoints',
      '--container-': 'containers',
      '--animate-': 'animation',
      '--ease-': 'easing',
      '--blur-': 'blur',
      '--perspective-': 'perspective',
      '--aspect-': 'aspectRatio'
    };

    // Extract all theme variables
    const varMatches = content.match(/--[\w-]+\s*:\s*[^;{]+/g) || [];
    
    for (const v of varMatches) {
      const [name, value] = v.split(':').map(s => s.trim());
      
      for (const [prefix, category] of Object.entries(namespaces)) {
        if (name.startsWith(prefix)) {
          const key = name.replace(prefix, '');
          if (!this.result.theme[category]) {
            this.result.theme[category] = {};
          }
          this.result.theme[category][key] = value.replace(';', '');
        }
      }
    }
  }

  parseThemeObject(themeStr, category) {
    // Simple object parser - extracts key-value pairs
    const colorsMatch = themeStr.match(/colors\s*:\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}/s);
    if (colorsMatch) {
      this.result.theme.colors = this.parseNestedObject(colorsMatch[0]);
    }

    const fontFamilyMatch = themeStr.match(/fontFamily\s*:\s*\{([^}]+)\}/s);
    if (fontFamilyMatch) {
      this.result.theme.fonts = this.parseNestedObject(fontFamilyMatch[0]);
    }

    const fontSizeMatch = themeStr.match(/fontSize\s*:\s*\{([^}]+)\}/s);
    if (fontSizeMatch) {
      this.result.theme.fontSizes = this.parseNestedObject(fontSizeMatch[0]);
    }

    const spacingMatch = themeStr.match(/spacing\s*:\s*\{([^}]+)\}/s);
    if (spacingMatch) {
      this.result.theme.spacing = this.parseNestedObject(spacingMatch[0]);
    }

    const borderRadiusMatch = themeStr.match(/borderRadius\s*:\s*\{([^}]+)\}/s);
    if (borderRadiusMatch) {
      this.result.theme.borderRadius = this.parseNestedObject(borderRadiusMatch[0]);
    }

    const boxShadowMatch = themeStr.match(/boxShadow\s*:\s*\{([^}]+)\}/s);
    if (boxShadowMatch) {
      this.result.theme.shadows = this.parseNestedObject(boxShadowMatch[0]);
    }

    const screensMatch = themeStr.match(/screens\s*:\s*\{([^}]+)\}/s);
    if (screensMatch) {
      this.result.theme.breakpoints = this.parseNestedObject(screensMatch[0]);
    }

    const zIndexMatch = themeStr.match(/zIndex\s*:\s*\{([^}]+)\}/s);
    if (zIndexMatch) {
      this.result.theme.zIndex = this.parseNestedObject(zIndexMatch[0]);
    }

    const animationMatch = themeStr.match(/animation\s*:\s*\{([^}]+)\}/s);
    if (animationMatch) {
      this.result.theme.animation = this.parseNestedObject(animationMatch[0]);
    }
  }

  parseNestedObject(str) {
    const obj = {};
    // Match nested key-value pairs
    const pairs = str.match(/(\w+)\s*:\s*['"`]([^'"`]+)['"`]/g);
    if (pairs) {
      pairs.forEach(pair => {
        const [key, value] = pair.split(/\s*:\s*/);
        obj[key.trim()] = value.replace(/['"`]/g, '').trim();
      });
    }
    
    // Match nested objects like colors: { primary: { 50: '#...', 100: '#...' } }
    const nestedMatch = str.match(/(\w+)\s*:\s*\{([^}]+)\}/g);
    if (nestedMatch) {
      nestedMatch.forEach(nested => {
        const key = nested.match(/^(\w+)/)[1];
        const nestedPairs = nested.match(/['"`]([^'"`]+)['"`]/g);
        if (nestedPairs && nestedPairs.length > 0) {
          obj[key] = nestedPairs.map(p => p.replace(/['"`]/g, ''));
        }
      });
    }
    
    return obj;
  }

  extractTheme() {
    // Check for theme.css or index.css in node_modules for default theme
    const themeCssPath = path.join(this.projectPath, 'node_modules', 'tailwindcss', 'theme.css');
    if (fs.existsSync(themeCssPath) && this.result.majorVersion >= 4) {
      const themeContent = fs.readFileSync(themeCssPath, 'utf-8');
      this.result.v4Features.defaultTheme = true;
    }
  }

  detectPlugins() {
    if (!this.result.configPath || this.result.configType !== 'js-config') return;
    
    const content = fs.readFileSync(this.result.configPath, 'utf-8');
    
    // Extract require() plugins
    const requireMatches = content.match(/require\(['"`]([^'"`]+)['"`]\)/g);
    if (requireMatches) {
      const plugins = requireMatches
        .map(m => m.match(/require\(['"`]([^'"`]+)['"`]\)/)[1])
        .filter(p => p.includes('tailwind') || p.includes('@tailwindcss'));
      
      this.result.plugins = [...this.result.plugins, ...plugins.map(p => ({ name: p }))];
    }

    // Extract import plugins (for v3 with ES modules)
    const importMatches = content.match(/import\s+\w+\s+from\s+['"`]([^'"`]+)['"`]/g);
    if (importMatches) {
      const plugins = importMatches
        .map(m => m.match(/from\s+['"`]([^'"`]+)['"`]/)[1])
        .filter(p => p.includes('tailwind') || p.includes('@tailwindcss'));
      
      this.result.plugins = [...this.result.plugins, ...plugins.map(p => ({ name: p }))];
    }
  }

  analyzeCustomizations() {
    // Count customizations
    const customizationCount = Object.keys(this.result.theme.colors).length +
      Object.keys(this.result.theme.fonts).length +
      Object.keys(this.result.theme.spacing).length +
      Object.keys(this.result.theme.borderRadius).length;

    if (customizationCount === 0 && this.result.v4Features.cssVariables.length === 0) {
      this.result.customizations.type = 'default';
      this.result.customizations.description = 'Using default Tailwind theme';
    } else if (customizationCount < 10) {
      this.result.customizations.type = 'light';
      this.result.customizations.description = 'Light customization (few custom tokens)';
    } else if (customizationCount < 30) {
      this.result.customizations.type = 'moderate';
      this.result.customizations.description = 'Moderate customization (custom brand colors, fonts)';
    } else {
      this.result.customizations.type = 'heavy';
      this.result.customizations.description = 'Heavy customization (complete custom design system)';
    }

    this.result.customizations.count = customizationCount;
    this.result.customizations.hasBrandColors = Object.keys(this.result.theme.colors).length > 0;
    this.result.customizations.hasCustomFonts = Object.keys(this.result.theme.fonts).length > 0;
    this.result.customizations.hasCustomSpacing = Object.keys(this.result.theme.spacing).length > 0;
    this.result.customizations.hasCustomRadius = Object.keys(this.result.theme.borderRadius).length > 0;
  }

  // ===== NEW ENHANCED FEATURES =====
  
  detectFrameworks() {
    const packageJsonPath = path.join(this.projectPath, 'package.json');
    if (!fs.existsSync(packageJsonPath)) return;
    
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
    const deps = { ...packageJson.dependencies, ...packageJson.devDependencies };
    
    this.result.frameworks = [];
    
    const frameworkMap = {
      // shadcn/ui ecosystem
      'class-variance-authority': { name: 'shadcn/ui', type: 'component-library', confidence: 'medium' },
      'radix-ui': { name: 'Radix UI', type: 'headless-components', confidence: 'high' },
      '@radix-ui/react-dialog': { name: 'Radix UI', type: 'headless-components', confidence: 'high' },
      '@radix-ui/react-select': { name: 'Radix UI', type: 'headless-components', confidence: 'high' },
      
      // DaisyUI
      'daisyui': { name: 'DaisyUI', type: 'component-library', confidence: 'high' },
      
      // Flowbite
      'flowbite': { name: 'Flowbite', type: 'component-library', confidence: 'high' },
      'flowbite-react': { name: 'Flowbite React', type: 'component-library', confidence: 'high' },
      
      // Headless UI (official)
      '@headlessui/react': { name: 'Headless UI', type: 'headless-components', confidence: 'high' },
      '@headlessui/vue': { name: 'Headless UI Vue', type: 'headless-components', confidence: 'high' },
      
      // Tailwind UI
      '@tailwindcss/ui': { name: 'Tailwind UI', type: 'official-components', confidence: 'high' },
      
      // Other popular
      'tw-elements': { name: 'TW Elements', type: 'component-library', confidence: 'high' },
      'preline': { name: 'Preline UI', type: 'component-library', confidence: 'high' },
      'rippleui': { name: 'Ripple UI', type: 'component-library', confidence: 'high' },
      'kitwind': { name: 'Kitwind', type: 'component-library', confidence: 'high' },
      
      // Animation
      'framer-motion': { name: 'Framer Motion', type: 'animation-library', confidence: 'medium' },
      'tailwindcss-animate': { name: 'Tailwind Animate', type: 'animation-plugin', confidence: 'high' },
      
      // Forms
      '@tailwindcss/forms': { name: 'Tailwind Forms', type: 'form-plugin', confidence: 'high' },
      
      // Typography
      '@tailwindcss/typography': { name: 'Tailwind Typography', type: 'typography-plugin', confidence: 'high' }
    };
    
    for (const [pkg, info] of Object.entries(frameworkMap)) {
      if (deps[pkg]) {
        this.result.frameworks.push({
          package: pkg,
          name: info.name,
          type: info.type,
          version: deps[pkg].replace(/^[\^~>=]/, ''),
          confidence: info.confidence
        });
      }
    }
    
    // Detect shadcn/ui specifically by folder structure
    const shadcnPaths = [
      'components/ui',
      'app/components/ui',
      'src/components/ui'
    ];
    
    for (const shadcnPath of shadcnPaths) {
      const fullPath = path.join(this.projectPath, shadcnPath);
      if (fs.existsSync(fullPath)) {
        const files = fs.readdirSync(fullPath);
        if (files.some(f => f.includes('button') || f.includes('input') || f.includes('dialog'))) {
          this.result.frameworks.push({
            package: 'shadcn/ui',
            name: 'shadcn/ui',
            type: 'component-library',
            version: 'detected-by-structure',
            confidence: 'high'
          });
          break;
        }
      }
    }
  }
  
  analyzeUsage() {
    this.result.usage = {
      tailwindClasses: {},
      arbitraryValues: [],
      responsivePrefixes: {},
      darkModeClasses: [],
      customClasses: [],
      hardcodedValues: [],
      stats: {
        totalFiles: 0,
        filesWithTailwind: 0,
        totalClasses: 0,
        uniqueClasses: 0
      }
    };
    
    const sourceFiles = this.findSourceFiles();
    this.result.usage.stats.totalFiles = sourceFiles.length;
    
    const allClasses = new Set();
    const tailwindRegex = /\b([a-z]+-[^\s"'`]+)/g;
    const arbitraryRegex = /\b([a-z]+-\[[^\]]+\])/g;
    const responsiveRegex = /\b(sm|md|lg|xl|2xl):/g;
    const darkModeRegex = /\bdark:([a-z-]+)/g;
    const hardcodedRegex = /(?:class|className)=\s*["']([^"']*(?:#[0-9a-fA-F]{3,8}|rgb\(|rgba\(|hsl\()[^"']*)["']/g;
    
    for (const file of sourceFiles.slice(0, 100)) { // Limit to 100 files for performance
      try {
        const content = fs.readFileSync(file, 'utf-8');
        const isHtml = file.endsWith('.html') || file.endsWith('.jsx') || file.endsWith('.tsx') || file.endsWith('.vue');
        
        if (!isHtml) continue;
        
        this.result.usage.stats.filesWithTailwind++;
        
        // Extract all Tailwind-like classes
        let match;
        while ((match = tailwindRegex.exec(content)) !== null) {
          const cls = match[1];
          allClasses.add(cls);
          this.result.usage.tailwindClasses[cls] = (this.result.usage.tailwindClasses[cls] || 0) + 1;
        }
        
        // Extract arbitrary values
        while ((match = arbitraryRegex.exec(content)) !== null) {
          this.result.usage.arbitraryValues.push({
            class: match[1],
            file: path.relative(this.projectPath, file)
          });
        }
        
        // Extract responsive prefixes
        while ((match = responsiveRegex.exec(content)) !== null) {
          const prefix = match[1];
          this.result.usage.responsivePrefixes[prefix] = (this.result.usage.responsivePrefixes[prefix] || 0) + 1;
        }
        
        // Extract dark mode classes
        while ((match = darkModeRegex.exec(content)) !== null) {
          this.result.usage.darkModeClasses.push({
            class: match[1],
            file: path.relative(this.projectPath, file)
          });
        }
        
        // Detect hardcoded colors
        while ((match = hardcodedRegex.exec(content)) !== null) {
          const classes = match[1];
          if (classes.includes('#') || classes.includes('rgb')) {
            this.result.usage.hardcodedValues.push({
              value: classes,
              file: path.relative(this.projectPath, file)
            });
          }
        }
      } catch (e) {
        // Skip files that can't be read
      }
    }
    
    this.result.usage.stats.uniqueClasses = allClasses.size;
    this.result.usage.stats.totalClasses = Object.values(this.result.usage.tailwindClasses).reduce((a, b) => a + b, 0);
    
    // Top used classes
    this.result.usage.topClasses = Object.entries(this.result.usage.tailwindClasses)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 20)
      .map(([name, count]) => ({ name, count }));
    
    // Coverage calculation
    const themeKeys = Object.keys(this.result.theme.colors).length + 
                      Object.keys(this.result.theme.spacing).length +
                      Object.keys(this.result.theme.fontSizes).length;
    
    if (themeKeys > 0) {
      const usedCustomTokens = Object.keys(this.result.usage.tailwindClasses).filter(cls => 
        Object.keys(this.result.theme.colors).some(c => cls.includes(c)) ||
        Object.keys(this.result.theme.spacing).some(s => cls.includes(s))
      ).length;
      
      this.result.usage.stats.tokenCoverage = Math.round((usedCustomTokens / themeKeys) * 100);
    } else {
      this.result.usage.stats.tokenCoverage = 0;
    }
  }
  
  detectBaseComponents() {
    this.result.baseComponents = {
      buttons: [],
      inputs: [],
      selects: [],
      textareas: [],
      labels: [],
      checkboxes: [],
      radios: [],
      switches: [],
      cards: [],
      modals: [],
      tables: [],
      navigation: [],
      tabs: [],
      alerts: [],
      badges: [],
      avatars: [],
      tooltips: []
    };
    
    const patterns = {
      buttons: ['button', 'btn', 'action-button', 'icon-button', 'submit-button', 'ghost-button'],
      inputs: ['input', 'text-field', 'text-input', 'form-input', 'number-input', 'password-input'],
      selects: ['select', 'dropdown', 'select-field', 'multi-select', 'autocomplete'],
      textareas: ['textarea', 'text-area', 'text-field', 'long-text-input', 'message-input'],
      labels: ['label', 'form-label', 'field-label', 'input-label'],
      checkboxes: ['checkbox', 'check-box', 'check', 'toggle', 'switch'],
      radios: ['radio', 'radio-button', 'radio-group', 'radio-input'],
      switches: ['switch', 'toggle', 'toggler', 'toggle-switch'],
      cards: ['card', 'info-card', 'product-card', 'feature-card'],
      modals: ['modal', 'dialog', 'overlay', 'drawer', 'sheet'],
      tables: ['table', 'data-table', 'grid', 'list'],
      navigation: ['nav', 'navbar', 'sidebar', 'menu', 'breadcrumb', 'pagination'],
      tabs: ['tabs', 'tab-list', 'tab-panel', 'tab-group'],
      alerts: ['alert', 'toast', 'notification', 'banner', 'message'],
      badges: ['badge', 'tag', 'pill', 'status-badge'],
      avatars: ['avatar', 'user-avatar', 'profile-image', 'initials'],
      tooltips: ['tooltip', 'popover', 'hint', 'help-text']
    };
    
    const sourceFiles = this.findSourceFiles();
    
    for (const file of sourceFiles) {
      try {
        const content = fs.readFileSync(file, 'utf-8').toLowerCase();
        const fileName = path.basename(file).toLowerCase();
        
        for (const [category, keywords] of Object.entries(patterns)) {
          for (const keyword of keywords) {
            // Check filename
            if (fileName.includes(keyword.replace('-', ''))) {
              const existing = this.result.baseComponents[category].find(c => c.name === keyword);
              if (!existing) {
                this.result.baseComponents[category].push({
                  name: keyword,
                  file: path.relative(this.projectPath, file),
                  detectedBy: 'filename'
                });
              }
            }
            
            // Check content for component definitions
            const componentRegex = new RegExp(`(?:function|const|class|interface)\\s+${keyword.replace(/-/g, '[-]?')}\\s*[{(<]`, 'i');
            if (componentRegex.test(content) || content.includes(keyword)) {
              const existing = this.result.baseComponents[category].find(c => c.name === keyword);
              if (!existing) {
                this.result.baseComponents[category].push({
                  name: keyword,
                  file: path.relative(this.projectPath, file),
                  detectedBy: 'content'
                });
              }
            }
          }
        }
      } catch (e) {
        // Skip
      }
    }
    
    // Count totals
    this.result.baseComponents.total = Object.values(this.result.baseComponents)
      .reduce((sum, arr) => sum + arr.length, 0);
  }
  
  findSourceFiles() {
    const extensions = ['.jsx', '.tsx', '.vue', '.svelte', '.html', '.astro'];
    const files = [];
    
    function scanDir(dir) {
      try {
        const entries = fs.readdirSync(dir, { withFileTypes: true });
        for (const entry of entries) {
          const fullPath = path.join(dir, entry.name);
          
          if (entry.isDirectory()) {
            // Skip node_modules, .next, dist, etc.
            if (['node_modules', '.next', 'dist', 'build', '.git', 'coverage'].includes(entry.name)) {
              continue;
            }
            scanDir(fullPath);
          } else if (entry.isFile() && extensions.some(ext => entry.name.endsWith(ext))) {
            files.push(fullPath);
          }
        }
      } catch (e) {
        // Skip directories that can't be read
      }
    }
    
    const srcPath = path.join(this.projectPath, 'src');
    const appPath = path.join(this.projectPath, 'app');
    const componentsPath = path.join(this.projectPath, 'components');
    
    if (fs.existsSync(srcPath)) scanDir(srcPath);
    if (fs.existsSync(appPath)) scanDir(appPath);
    if (fs.existsSync(componentsPath)) scanDir(componentsPath);
    
    // Also scan root level for non-standard structures
    if (files.length === 0) {
      scanDir(this.projectPath);
    }
    
    return files;
  }

  // Utility: Check if file exists
  fileExists(filePath) {
    return fs.existsSync(path.join(this.projectPath, filePath));
  }
}

// CLI execution
if (require.main === module) {
  const projectPath = process.argv[2] || process.cwd();
  const detector = new TailwindDetector(projectPath);
  const result = detector.detect();
  console.log(JSON.stringify(result, null, 2));
}

module.exports = TailwindDetector;
