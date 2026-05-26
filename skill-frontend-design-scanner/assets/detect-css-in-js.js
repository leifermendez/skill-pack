#!/usr/bin/env node
/**
 * CSS-in-JS Detection Script
 * Detects styled-components, Emotion, Linaria, vanilla-extract, and extracts tokens
 * Usage: node detect-css-in-js.js <project-path>
 */

const fs = require('fs');
const path = require('path');
const { glob } = require('glob');

class CSSInJSDetector {
  constructor(projectPath) {
    this.projectPath = projectPath;
    this.result = {
      detected: false,
      libraries: [],
      styledComponents: {
        detected: false,
        version: null,
        components: [],
        theme: {}
      },
      emotion: {
        detected: false,
        version: null,
        cssProps: [],
        theme: {}
      },
      linaria: {
        detected: false,
        atomic: false
      },
      vanillaExtract: {
        detected: false,
        files: []
      },
      tokens: {
        colors: [],
        fonts: [],
        spacing: [],
        borderRadius: []
      },
      errors: []
    };
  }

  async detect() {
    try {
      this.detectViaPackageJson();
      this.detectStyledComponents();
      this.detectEmotion();
      this.detectLinaria();
      this.detectVanillaExtract();
      this.extractTokens();
    } catch (error) {
      this.result.errors.push(error.message);
    }
    return this.result;
  }

  detectViaPackageJson() {
    const packageJsonPath = path.join(this.projectPath, 'package.json');
    if (!fs.existsSync(packageJsonPath)) return;

    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
    const deps = {
      ...packageJson.dependencies,
      ...packageJson.devDependencies
    };

    const libraries = {
      'styled-components': 'styled-components',
      '@emotion/react': 'emotion',
      '@emotion/styled': 'emotion',
      '@emotion/css': 'emotion',
      'emotion': 'emotion',
      '@linaria/core': 'linaria',
      'linaria': 'linaria',
      '@vanilla-extract/css': 'vanilla-extract',
      'vanilla-extract': 'vanilla-extract'
    };

    for (const [dep, lib] of Object.entries(libraries)) {
      if (deps[dep]) {
        this.result.detected = true;
        this.result.libraries.push({
          name: lib,
          package: dep,
          version: deps[dep].replace('^', '').replace('~', '')
        });
      }
    }
  }

  detectStyledComponents() {
    const lib = this.result.libraries.find(l => l.name === 'styled-components');
    if (!lib) return;

    this.result.styledComponents.detected = true;
    this.result.styledComponents.version = lib.version;

    // Scan for styled component definitions
    const patterns = [
      'src/**/*.{js,jsx,ts,tsx}',
      'components/**/*.{js,jsx,ts,tsx}'
    ];

    for (const pattern of patterns) {
      try {
        const files = glob.sync(pattern, {
          cwd: this.projectPath,
          ignore: ['**/node_modules/**', '**/.next/**', '**/dist/**']
        });

        for (const file of files) {
          const content = fs.readFileSync(path.join(this.projectPath, file), 'utf-8');
          
          // Detect styled components
          const styledMatches = content.match(/styled\.[a-z]+`[^`]+`/g);
          if (styledMatches) {
            this.result.styledComponents.components.push({
              file,
              count: styledMatches.length
            });
          }

          // Detect theme provider
          const themeMatch = content.match(/ThemeProvider|theme\s*=\s*\{/);
          if (themeMatch) {
            const themeObj = content.match(/theme\s*=\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}/s);
            if (themeObj) {
              this.result.styledComponents.theme.raw = themeObj[0];
            }
          }
        }
      } catch {
        // Continue
      }
    }
  }

  detectEmotion() {
    const lib = this.result.libraries.find(l => l.name === 'emotion');
    if (!lib) return;

    this.result.emotion.detected = true;
    this.result.emotion.version = lib.version;

    const patterns = [
      'src/**/*.{js,jsx,ts,tsx}',
      'components/**/*.{js,jsx,ts,tsx}'
    ];

    for (const pattern of patterns) {
      try {
        const files = glob.sync(pattern, {
          cwd: this.projectPath,
          ignore: ['**/node_modules/**', '**/.next/**', '**/dist/**']
        });

        for (const file of files) {
          const content = fs.readFileSync(path.join(this.projectPath, file), 'utf-8');
          
          // css`` template literals
          const cssMatches = content.match(/css`[^`]+`/g);
          if (cssMatches) {
            this.result.emotion.cssProps.push({
              file,
              count: cssMatches.length
            });
          }
        }
      } catch {
        // Continue
      }
    }
  }

  detectLinaria() {
    const lib = this.result.libraries.find(l => l.name === 'linaria');
    if (!lib) return;

    this.result.linaria.detected = true;
    
    // Check for atomic CSS flag
    const packageJsonPath = path.join(this.projectPath, 'package.json');
    if (fs.existsSync(packageJsonPath)) {
      const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
      if (packageJson.dependencies?.['@linaria/atomic'] || packageJson.devDependencies?.['@linaria/atomic']) {
        this.result.linaria.atomic = true;
      }
    }
  }

  detectVanillaExtract() {
    const lib = this.result.libraries.find(l => l.name === 'vanilla-extract');
    if (!lib) return;

    this.result.vanillaExtract.detected = true;

    // Find .css.ts files
    const patterns = [
      'src/**/*.css.ts',
      'src/**/*.css.js',
      'styles/**/*.css.ts'
    ];

    for (const pattern of patterns) {
      try {
        const files = glob.sync(pattern, {
          cwd: this.projectPath,
          ignore: ['**/node_modules/**']
        });
        this.result.vanillaExtract.files.push(...files);
      } catch {
        // Continue
      }
    }
  }

  extractTokens() {
    if (!this.result.detected) return;

    // Extract from styled-components and emotion files
    const allFiles = [
      ...(this.result.styledComponents.components.map(c => c.file) || []),
      ...(this.result.emotion.cssProps.map(c => c.file) || []),
      ...(this.result.vanillaExtract.files || [])
    ];

    for (const file of [...new Set(allFiles)].slice(0, 20)) {
      try {
        const content = fs.readFileSync(path.join(this.projectPath, file), 'utf-8');
        
        // Extract colors from template literals
        const colorMatches = content.match(/(color|background|backgroundColor|borderColor)\s*:\s*['"]([^'"]+)['"]/g);
        if (colorMatches) {
          colorMatches.forEach(match => {
            const color = match.match(/['"]([^'"]+)['"]/)?.[1];
            if (color && this.isColor(color)) {
              this.result.tokens.colors.push({
                value: color,
                file,
                context: match
              });
            }
          });
        }

        // Extract font tokens
        const fontMatches = content.match(/(fontFamily|fontSize|fontWeight)\s*:\s*['"]([^'"]+)['"]/g);
        if (fontMatches) {
          fontMatches.forEach(match => {
            const prop = match.match(/(fontFamily|fontSize|fontWeight)/)?.[1];
            const value = match.match(/['"]([^'"]+)['"]/)?.[1];
            if (value) {
              this.result.tokens.fonts.push({
                property: prop,
                value,
                file
              });
            }
          });
        }

        // Extract spacing
        const spacingMatches = content.match(/(margin|padding|gap)\s*:\s*['"]([^'"]+)['"]/g);
        if (spacingMatches) {
          spacingMatches.forEach(match => {
            const value = match.match(/['"]([^'"]+)['"]/)?.[1];
            if (value) {
              this.result.tokens.spacing.push({
                value,
                file
              });
            }
          });
        }

        // Extract border radius
        const radiusMatches = content.match(/(borderRadius)\s*:\s*['"]([^'"]+)['"]/g);
        if (radiusMatches) {
          radiusMatches.forEach(match => {
            const value = match.match(/['"]([^'"]+)['"]/)?.[1];
            if (value) {
              this.result.tokens.borderRadius.push({
                value,
                file
              });
            }
          });
        }
      } catch {
        // Skip unreadable files
      }
    }
  }

  isColor(value) {
    return /^#([0-9A-Fa-f]{3}){1,2}$/.test(value) ||
           /^rgb\(/.test(value) ||
           /^rgba\(/.test(value) ||
           /^hsl\(/.test(value) ||
           /^(red|blue|green|yellow|orange|purple|pink|black|white|gray|grey|transparent|currentColor)$/.test(value);
  }
}

// CLI execution
if (require.main === module) {
  const projectPath = process.argv[2] || process.cwd();
  const detector = new CSSInJSDetector(projectPath);
  detector.detect().then(result => {
    console.log(JSON.stringify(result, null, 2));
  });
}

module.exports = CSSInJSDetector;
