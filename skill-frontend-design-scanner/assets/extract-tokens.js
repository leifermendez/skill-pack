#!/usr/bin/env node
/**
 * Design Token Extraction Script
 * Extracts fonts, colors, spacing, border radius, shadows from CSS/SCSS/Config files
 * Usage: node extract-tokens.js <project-path>
 */

const fs = require('fs');
const path = require('path');
const { glob } = require('glob');

class TokenExtractor {
  constructor(projectPath) {
    this.projectPath = projectPath;
    this.result = {
      fonts: {
        families: [],
        sizes: [],
        weights: new Set(),
        styles: new Set()
      },
      colors: {
        primary: null,
        secondary: null,
        accent: null,
        neutrals: [],
        semantic: {},
        all: []
      },
      borderRadius: [],
      spacing: [],
      shadows: [],
      cssVariables: {},
      errors: []
    };
    this.allDeclarations = [];
  }

  async extract() {
    try {
      await this.scanStyleFiles();
      this.extractCSSVariables();
      this.extractFontTokens();
      this.extractColorTokens();
      this.extractBorderRadiusTokens();
      this.extractSpacingTokens();
      this.extractShadowTokens();
      this.normalizeTokens();
    } catch (error) {
      this.result.errors.push(error.message);
    }
    return this.result;
  }

  async scanStyleFiles() {
    const patterns = [
      '**/*.css',
      '**/*.scss',
      '**/*.sass',
      '**/*.less',
      'tailwind.config.*',
      'theme.*',
      'tokens.*'
    ];

    for (const pattern of patterns) {
      try {
        const files = await glob(pattern, {
          cwd: this.projectPath,
          ignore: ['**/node_modules/**', '**/.next/**', '**/dist/**', '**/build/**']
        });
        
        for (const file of files) {
          const fullPath = path.join(this.projectPath, file);
          try {
            const content = fs.readFileSync(fullPath, 'utf-8');
            
            // Extract all CSS declarations
            const declarations = content.match(/[\w-]+\s*:\s*[^;]+;/g) || [];
            this.allDeclarations.push(...declarations.map(d => ({
              declaration: d,
              file: fullPath,
              isConfig: file.includes('tailwind.config') || file.includes('theme.')
            })));
          } catch {
            // Skip unreadable files
          }
        }
      } catch {
        // Pattern not supported
      }
    }
  }

  extractCSSVariables() {
    const vars = {};
    
    for (const { declaration, file } of this.allDeclarations) {
      // CSS custom properties
      const varMatch = declaration.match(/--([\w-]+)\s*:\s*([^;]+);/);
      if (varMatch) {
        const [, name, value] = varMatch;
        vars[`--${name}`] = {
          value: value.trim(),
          file: path.relative(this.projectPath, file)
        };
      }
    }
    
    this.result.cssVariables = vars;
    
    // Categorize variables
    for (const [varName, data] of Object.entries(vars)) {
      const name = varName.toLowerCase();
      
      if (name.includes('font') || name.includes('typography')) {
        if (name.includes('family') || name.includes('stack')) {
          this.result.fonts.families.push({ name: varName, ...data });
        }
        if (name.includes('size')) {
          this.result.fonts.sizes.push({ name: varName, ...data, px: this.toPixels(data.value) });
        }
      }
      
      if (name.includes('color') || name.includes('primary') || name.includes('secondary')) {
        this.result.colors.all.push({ name: varName, ...data });
      }
      
      if (name.includes('radius') || name.includes('rounded')) {
        this.result.borderRadius.push({ name: varName, ...data, px: this.toPixels(data.value) });
      }
      
      if (name.includes('spacing') || name.includes('space') || name.includes('gap')) {
        this.result.spacing.push({ name: varName, ...data, px: this.toPixels(data.value) });
      }
    }
  }

  extractFontTokens() {
    const families = new Set();
    const sizes = new Map();
    const weights = new Set();
    const styles = new Set();
    
    for (const { declaration } of this.allDeclarations) {
      // Font family
      const familyMatch = declaration.match(/font-family\s*:\s*([^;]+);/);
      if (familyMatch) {
        const value = familyMatch[1].trim();
        families.add(value);
      }
      
      // Font size
      const sizeMatch = declaration.match(/font-size\s*:\s*([^;]+);/);
      if (sizeMatch) {
        const value = sizeMatch[1].trim();
        const px = this.toPixels(value);
        if (px) {
          sizes.set(px, (sizes.get(px) || 0) + 1);
        }
      }
      
      // Font weight
      const weightMatch = declaration.match(/font-weight\s*:\s*([^;]+);/);
      if (weightMatch) {
        const value = weightMatch[1].trim();
        if (!isNaN(value) || ['normal', 'bold', 'lighter', 'bolder'].includes(value)) {
          weights.add(value);
        }
      }
      
      // Font style
      const styleMatch = declaration.match(/font-style\s*:\s*([^;]+);/);
      if (styleMatch) {
        styles.add(styleMatch[1].trim());
      }
    }
    
    // Add to result if not already from CSS variables
    if (this.result.fonts.families.length === 0) {
      this.result.fonts.families = [...families].map(f => ({
        value: f,
        name: this.extractFontName(f),
        fallback: this.extractFallback(f)
      }));
    }
    
    if (this.result.fonts.sizes.length === 0) {
      this.result.fonts.sizes = [...sizes.entries()]
        .map(([px, count]) => ({ px, value: `${px}px`, usageCount: count }))
        .sort((a, b) => a.px - b.px);
    }
    
    this.result.fonts.weights = [...weights];
    this.result.fonts.styles = [...styles];
  }

  extractColorTokens() {
    const colors = new Set();
    const colorValues = new Map();
    
    for (const { declaration } of this.allDeclarations) {
      // All color properties
      const colorMatch = declaration.match(/(?:color|background-color|border-color|fill|stroke)\s*:\s*([^;]+);/);
      if (colorMatch) {
        const value = colorMatch[1].trim();
        if (this.isColor(value)) {
          colors.add(value);
          colorValues.set(value, (colorValues.get(value) || 0) + 1);
        }
      }
    }
    
    // Analyze color palette
    const sortedColors = [...colorValues.entries()]
      .sort((a, b) => b[1] - a[1]);
    
    if (sortedColors.length > 0) {
      this.result.colors.all = sortedColors.map(([value, count]) => ({
        value,
        usageCount: count,
        hex: this.normalizeColor(value)
      }));
      
      // Identify primary, secondary, accent
      const uniqueColors = [...new Set(sortedColors.map(([value]) => this.normalizeColor(value)))];
      
      if (uniqueColors.length > 0) this.result.colors.primary = uniqueColors[0];
      if (uniqueColors.length > 1) this.result.colors.secondary = uniqueColors[1];
      if (uniqueColors.length > 2) this.result.colors.accent = uniqueColors[2];
      
      // Identify neutrals (grays)
      this.result.colors.neutrals = uniqueColors
        .filter(c => this.isNeutral(c))
        .slice(0, 5);
      
      // Identify semantic colors
      for (const [value, count] of sortedColors) {
        const lower = value.toLowerCase();
        if (lower.includes('success') || lower.includes('green')) {
          this.result.colors.semantic.success = this.normalizeColor(value);
        }
        if (lower.includes('error') || lower.includes('danger') || lower.includes('red')) {
          this.result.colors.semantic.error = this.normalizeColor(value);
        }
        if (lower.includes('warning') || lower.includes('yellow') || lower.includes('orange')) {
          this.result.colors.semantic.warning = this.normalizeColor(value);
        }
        if (lower.includes('info') || lower.includes('blue')) {
          this.result.colors.semantic.info = this.normalizeColor(value);
        }
      }
    }
  }

  extractBorderRadiusTokens() {
    const radiusMap = new Map();
    
    for (const { declaration } of this.allDeclarations) {
      const radiusMatch = declaration.match(/border-radius\s*:\s*([^;]+);/);
      if (radiusMatch) {
        const value = radiusMatch[1].trim();
        const px = this.toPixels(value);
        if (px !== null) {
          radiusMap.set(px, (radiusMap.get(px) || 0) + 1);
        }
      }
    }
    
    this.result.borderRadius = [...radiusMap.entries()]
      .map(([px, count]) => ({
        px,
        value: px === 9999 || px === 100 ? '9999px (pill)' : `${px}px`,
        usageCount: count
      }))
      .sort((a, b) => a.px - b.px);
  }

  extractSpacingTokens() {
    const spacingMap = new Map();
    
    for (const { declaration } of this.allDeclarations) {
      const properties = [
        'margin', 'padding', 'gap', 'row-gap', 'column-gap',
        'top', 'right', 'bottom', 'left',
        'width', 'height', 'min-width', 'max-width'
      ];
      
      for (const prop of properties) {
        const match = declaration.match(new RegExp(`${prop}\\s*:\\s*([^;]+);`));
        if (match) {
          const value = match[1].trim();
          const px = this.toPixels(value);
          if (px !== null && px >= 0 && px <= 200) {
            spacingMap.set(px, (spacingMap.get(px) || 0) + 1);
          }
        }
      }
    }
    
    this.result.spacing = [...spacingMap.entries()]
      .map(([px, count]) => ({
        px,
        value: `${px}px`,
        usageCount: count
      }))
      .sort((a, b) => a.px - b.px)
      .slice(0, 20); // Limit to top 20
  }

  extractShadowTokens() {
    const shadows = new Set();
    
    for (const { declaration } of this.allDeclarations) {
      const shadowMatch = declaration.match(/box-shadow\s*:\s*([^;]+);/);
      if (shadowMatch) {
        shadows.add(shadowMatch[1].trim());
      }
    }
    
    this.result.shadows = [...shadows].slice(0, 10); // Limit to 10 unique shadows
  }

  normalizeTokens() {
    // Deduplicate font sizes
    const sizeMap = new Map();
    for (const size of this.result.fonts.sizes) {
      const key = size.px || size.value;
      if (!sizeMap.has(key) || size.usageCount > sizeMap.get(key).usageCount) {
        sizeMap.set(key, size);
      }
    }
    this.result.fonts.sizes = [...sizeMap.values()].sort((a, b) => (a.px || 0) - (b.px || 0));
    
    // Convert Sets to Arrays
    this.result.fonts.weights = [...this.result.fonts.weights];
    this.result.fonts.styles = [...this.result.fonts.styles];
  }

  // Utility methods
  toPixels(value) {
    if (!value) return null;
    
    value = value.trim();
    
    // Already in px
    if (value.endsWith('px')) {
      return parseFloat(value);
    }
    
    // rem to px (assuming 16px base)
    if (value.endsWith('rem')) {
      return parseFloat(value) * 16;
    }
    
    // em to px (approximate)
    if (value.endsWith('em')) {
      return parseFloat(value) * 16;
    }
    
    // Percentages (skip for most sizing)
    if (value.endsWith('%')) {
      return null;
    }
    
    // Numeric zero
    if (value === '0') {
      return 0;
    }
    
    // Special keywords
    if (value === 'auto') return null;
    if (value === 'inherit') return null;
    if (value === 'none') return null;
    
    // Try parsing as number
    const num = parseFloat(value);
    if (!isNaN(num) && num >= 0) {
      return num;
    }
    
    return null;
  }

  isColor(value) {
    return /^#([0-9A-Fa-f]{3}){1,2}$/.test(value) ||
           /^rgb\(/.test(value) ||
           /^rgba\(/.test(value) ||
           /^hsl\(/.test(value) ||
           /^hwb\(/.test(value) ||
           /^color\(/.test(value) ||
           /^(red|blue|green|yellow|orange|purple|pink|black|white|gray|grey|transparent|currentColor)$/.test(value);
  }

  normalizeColor(value) {
    // Convert to hex when possible
    if (value.startsWith('#')) {
      return value.toLowerCase();
    }
    
    // Simple rgb
    const rgbMatch = value.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
    if (rgbMatch) {
      const r = parseInt(rgbMatch[1]).toString(16).padStart(2, '0');
      const g = parseInt(rgbMatch[2]).toString(16).padStart(2, '0');
      const b = parseInt(rgbMatch[3]).toString(16).padStart(2, '0');
      return `#${r}${g}${b}`;
    }
    
    return value;
  }

  isNeutral(color) {
    const hex = this.normalizeColor(color);
    if (!hex.startsWith('#')) return false;
    
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    
    // Check if it's grayscale (r, g, b are very close)
    const maxDiff = Math.max(Math.abs(r - g), Math.abs(g - b), Math.abs(r - b));
    return maxDiff < 15;
  }

  extractFontName(fontFamily) {
    const match = fontFamily.match(/^['"]?([^,'"]+)/);
    return match ? match[1].trim() : fontFamily;
  }

  extractFallback(fontFamily) {
    const parts = fontFamily.split(',').slice(1);
    return parts.map(p => p.trim()).join(', ') || 'system-ui, sans-serif';
  }
}

// CLI execution
if (require.main === module) {
  const projectPath = process.argv[2] || process.cwd();
  const extractor = new TokenExtractor(projectPath);
  extractor.extract().then(result => {
    console.log(JSON.stringify(result, null, 2));
  });
}

module.exports = TokenExtractor;
