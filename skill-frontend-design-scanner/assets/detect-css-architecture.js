#!/usr/bin/env node
/**
 * CSS Architecture Detection Script
 * Detects BEM, Atomic Design, SMACSS, ITCSS, OOCSS, Utility-first patterns
 * Usage: node detect-css-architecture.js <project-path>
 */

const fs = require('fs');
const path = require('path');
const { glob } = require('glob');

class CSSArchitectureDetector {
  constructor(projectPath) {
    this.projectPath = projectPath;
    this.result = {
      methodologies: [],
      confidence: {},
      folderStructure: {},
      namingPatterns: {},
      fileOrganization: {},
      errors: []
    };
    this.cssFiles = [];
    this.classNames = [];
  }

  async detect() {
    try {
      await this.scanCSSFiles();
      this.analyzeFolderStructure();
      this.analyzeNamingPatterns();
      this.analyzeFileOrganization();
      this.calculateConfidence();
    } catch (error) {
      this.result.errors.push(error.message);
    }
    return this.result;
  }

  async scanCSSFiles() {
    const patterns = [
      '**/*.css',
      '**/*.scss',
      '**/*.sass',
      '**/*.less',
      '**/*.styl',
      '**/*.module.css',
      '**/*.module.scss'
    ];

    for (const pattern of patterns) {
      try {
        const files = await glob(pattern, {
          cwd: this.projectPath,
          ignore: ['**/node_modules/**', '**/.next/**', '**/dist/**', '**/build/**', '**/coverage/**']
        });
        this.cssFiles.push(...files.map(f => path.join(this.projectPath, f)));
      } catch {
        // Pattern not supported or no files
      }
    }

    // Extract class names from all CSS files
    for (const file of this.cssFiles.slice(0, 50)) { // Limit to 50 files for performance
      try {
        const content = fs.readFileSync(file, 'utf-8');
        const matches = content.match(/\.([a-zA-Z][\w-]*)/g);
        if (matches) {
          this.classNames.push(...matches.map(m => m.substring(1)));
        }
      } catch {
        // Skip unreadable files
      }
    }
  }

  analyzeFolderStructure() {
    const structure = {
      atomic: { score: 0, found: [] },
      bem: { score: 0, found: [] },
      smacss: { score: 0, found: [] },
      itcss: { score: 0, found: [] }
    };

    const checkFolders = [
      // Atomic Design
      { path: 'atoms', method: 'atomic', weight: 25 },
      { path: 'molecules', method: 'atomic', weight: 25 },
      { path: 'organisms', method: 'atomic', weight: 25 },
      { path: 'templates', method: 'atomic', weight: 15 },
      { path: 'pages', method: 'atomic', weight: 10 },
      
      // SMACSS
      { path: 'base', method: 'smacss', weight: 20 },
      { path: 'layout', method: 'smacss', weight: 20 },
      { path: 'module', method: 'smacss', weight: 20 },
      { path: 'modules', method: 'smacss', weight: 20 },
      { path: 'state', method: 'smacss', weight: 15 },
      { path: 'theme', method: 'smacss', weight: 5 },
      
      // ITCSS
      { path: 'settings', method: 'itcss', weight: 15 },
      { path: 'tools', method: 'itcss', weight: 15 },
      { path: 'generic', method: 'itcss', weight: 15 },
      { path: 'elements', method: 'itcss', weight: 15 },
      { path: 'objects', method: 'itcss', weight: 15 },
      { path: 'components', method: 'itcss', weight: 15 },
      { path: 'trumps', method: 'itcss', weight: 10 }
    ];

    for (const check of checkFolders) {
      const checkPath = path.join(this.projectPath, 'src', check.path);
      const altPath = path.join(this.projectPath, check.path);
      
      if (fs.existsSync(checkPath) || fs.existsSync(altPath)) {
        structure[check.method].score += check.weight;
        structure[check.method].found.push(check.path);
      }
    }

    this.result.folderStructure = structure;
  }

  analyzeNamingPatterns() {
    const patterns = {
      bem: 0,
      oocss: 0,
      utility: 0,
      module: 0
    };

    const totalClasses = this.classNames.length;
    if (totalClasses === 0) return;

    for (const className of this.classNames) {
      // BEM detection: block__element--modifier
      if (/^[a-z][a-z0-9-]*__[a-z][a-z0-9-]*(--[a-z][a-z0-9-]*)?$/.test(className)) {
        patterns.bem++;
      }
      
      // OOCSS: structure vs skin separation (simplified)
      if (/^(layout|container|wrapper|media|flag|band|island)$/.test(className)) {
        patterns.oocss++;
      }
      
      // Utility-first: single purpose, short names
      if (/^(flex|block|inline|hidden|relative|absolute|fixed|sticky|float|clear|overflow|visible|scroll|auto|static)$/.test(className) ||
          /^(p|m|px|py|mx|my|pt|pr|pb|pl|mt|mr|mb|ml)-\d+$/.test(className) ||
          /^(w|h|min-w|max-w|min-h|max-h)-\w+$/.test(className)) {
        patterns.utility++;
      }
      
      // CSS Modules: camelCase or component-specific
      if (/^[A-Z][a-zA-Z]*_[\w]+$/.test(className) || className.includes('_')) {
        patterns.module++;
      }
    }

    this.result.namingPatterns = {
      bem: { count: patterns.bem, percentage: (patterns.bem / totalClasses * 100).toFixed(2) },
      oocss: { count: patterns.oocss, percentage: (patterns.oocss / totalClasses * 100).toFixed(2) },
      utility: { count: patterns.utility, percentage: (patterns.utility / totalClasses * 100).toFixed(2) },
      module: { count: patterns.module, percentage: (patterns.module / totalClasses * 100).toFixed(2) },
      totalClasses
    };
  }

  analyzeFileOrganization() {
    const org = {
      byComponent: 0,      // Button.css next to Button.jsx
      byType: 0,         // all CSS in styles/
      coLocated: 0,      // CSS in same folder as component
      global: 0          // global styles
    };

    const srcPath = path.join(this.projectPath, 'src');
    if (!fs.existsSync(srcPath)) return;

    for (const file of this.cssFiles.slice(0, 30)) {
      const relativePath = path.relative(this.projectPath, file);
      
      if (relativePath.includes('styles/') || relativePath.includes('css/') || relativePath.includes('scss/')) {
        org.byType++;
      } else if (relativePath.includes('components/') || relativePath.includes('component/')) {
        org.coLocated++;
      } else if (relativePath.includes('global') || relativePath.includes('main.') || relativePath.includes('index.')) {
        org.global++;
      } else {
        org.byComponent++;
      }
    }

    this.result.fileOrganization = org;
  }

  calculateConfidence() {
    const scores = {
      atomic: 0,
      bem: 0,
      smacss: 0,
      itcss: 0,
      oocss: 0,
      utility: 0,
      module: 0
    };

    // Folder structure contributes 40%
    const folderScores = this.result.folderStructure;
    if (folderScores.atomic) scores.atomic += folderScores.atomic.score * 0.4;
    if (folderScores.smacss) scores.smacss += folderScores.smacss.score * 0.4;
    if (folderScores.itcss) scores.itcss += folderScores.itcss.score * 0.4;

    // Naming patterns contributes 40%
    const naming = this.result.namingPatterns;
    if (naming.bem && naming.bem.percentage > 20) scores.bem += Math.min(naming.bem.percentage, 40);
    if (naming.oocss && naming.oocss.percentage > 10) scores.oocss += Math.min(naming.oocss.percentage * 2, 40);
    if (naming.utility && naming.utility.percentage > 30) scores.utility += Math.min(naming.utility.percentage, 40);
    if (naming.module && naming.module.percentage > 20) scores.module += Math.min(naming.module.percentage, 40);

    // File organization contributes 20%
    const org = this.result.fileOrganization;
    const totalOrg = org.byComponent + org.byType + org.coLocated + org.global;
    if (totalOrg > 0) {
      if (org.coLocated / totalOrg > 0.3) scores.atomic += 20;
      if (org.byType / totalOrg > 0.5) {
        scores.smacss += 10;
        scores.itcss += 10;
      }
    }

    // Normalize to 0-100
    for (const [method, score] of Object.entries(scores)) {
      this.result.confidence[method] = Math.min(Math.round(score), 100);
    }

    // Determine primary and secondary
    const sorted = Object.entries(this.result.confidence)
      .sort((a, b) => b[1] - a[1])
      .filter(([_, score]) => score > 0);

    if (sorted.length > 0) {
      this.result.primary = sorted[0][0];
      this.result.primaryConfidence = sorted[0][1];
      
      if (sorted.length > 1 && sorted[1][1] > 20) {
        this.result.secondary = sorted[1][0];
        this.result.secondaryConfidence = sorted[1][1];
      }
    }
  }
}

// CLI execution
if (require.main === module) {
  const projectPath = process.argv[2] || process.cwd();
  const detector = new CSSArchitectureDetector(projectPath);
  detector.detect().then(result => {
    console.log(JSON.stringify(result, null, 2));
  });
}

module.exports = CSSArchitectureDetector;
