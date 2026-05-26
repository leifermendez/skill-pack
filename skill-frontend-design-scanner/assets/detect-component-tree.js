#!/usr/bin/env node
/**
 * Component Tree Detection Script
 * Maps component hierarchy and identifies base components
 * Supports: React (.jsx/.tsx), Vue (.vue), Svelte (.svelte), Astro (.astro)
 * Usage: node detect-component-tree.js <project-path>
 */

const fs = require('fs');
const path = require('path');
const { glob } = require('glob');

class ComponentTreeDetector {
  constructor(projectPath) {
    this.projectPath = projectPath;
    this.result = {
      totalComponents: 0,
      byFramework: {},
      byLevel: {
        atoms: [],
        molecules: [],
        organisms: [],
        templates: [],
        pages: [],
        unknown: []
      },
      baseComponents: {
        buttons: [],
        inputs: [],
        selects: [],
        textareas: [],
        labels: [],
        checkboxes: [],
        radios: [],
        switches: []
      },
      componentGraph: {},
      mostReused: [],
      errors: []
    };
    this.components = [];
  }

  async detect() {
    try {
      await this.scanComponents();
      this.identifyFrameworks();
      this.classifyByLevel();
      this.identifyBaseComponents();
      this.buildDependencyGraph();
      this.findMostReused();
    } catch (error) {
      this.result.errors.push(error.message);
    }
    return this.result;
  }

  async scanComponents() {
    const patterns = [
      'src/**/*.{jsx,tsx}',
      'src/**/*.vue',
      'src/**/*.svelte',
      'src/**/*.astro',
      'components/**/*.{jsx,tsx}',
      'components/**/*.vue',
      'components/**/*.svelte',
      'app/**/*.{jsx,tsx}'
    ];

    for (const pattern of patterns) {
      try {
        const files = await glob(pattern, {
          cwd: this.projectPath,
          ignore: ['**/node_modules/**', '**/.next/**', '**/dist/**', '**/build/**', '**/*.test.*', '**/*.spec.*']
        });
        
        for (const file of files) {
          const fullPath = path.join(this.projectPath, file);
          const ext = path.extname(file);
          const name = path.basename(file, ext);
          
          this.components.push({
            path: fullPath,
            relativePath: file,
            name,
            extension: ext,
            content: fs.readFileSync(fullPath, 'utf-8')
          });
        }
      } catch {
        // Skip patterns that don't match
      }
    }

    this.result.totalComponents = this.components.length;
  }

  identifyFrameworks() {
    const frameworks = {
      react: 0,
      vue: 0,
      svelte: 0,
      astro: 0
    };

    for (const comp of this.components) {
      if (comp.extension.match(/\.jsx?$/)) frameworks.react++;
      if (comp.extension === '.tsx') frameworks.react++;
      if (comp.extension === '.vue') frameworks.vue++;
      if (comp.extension === '.svelte') frameworks.svelte++;
      if (comp.extension === '.astro') frameworks.astro++;
    }

    this.result.byFramework = frameworks;
    this.result.primaryFramework = Object.entries(frameworks)
      .sort((a, b) => b[1] - a[1])[0]?.[0] || 'unknown';
  }

  classifyByLevel() {
    for (const comp of this.components) {
      const relativePath = comp.relativePath.toLowerCase();
      const name = comp.name.toLowerCase();
      
      // Check path for atomic design indicators
      if (relativePath.includes('/atoms/') || relativePath.includes('/atom/')) {
        this.result.byLevel.atoms.push(comp.name);
      } else if (relativePath.includes('/molecules/') || relativePath.includes('/molecule/')) {
        this.result.byLevel.molecules.push(comp.name);
      } else if (relativePath.includes('/organisms/') || relativePath.includes('/organism/')) {
        this.result.byLevel.organisms.push(comp.name);
      } else if (relativePath.includes('/templates/') || relativePath.includes('/template/')) {
        this.result.byLevel.templates.push(comp.name);
      } else if (relativePath.includes('/pages/') || relativePath.includes('/page/') || relativePath.includes('/app/')) {
        this.result.byLevel.pages.push(comp.name);
      } else {
        // Classify by component characteristics
        this.classifyByContent(comp);
      }
    }
  }

  classifyByContent(comp) {
    const content = comp.content;
    const name = comp.name.toLowerCase();
    
    // Atoms: simple wrappers, basic HTML elements
    const atomPatterns = /^(button|input|label|span|div|text|icon|image|avatar|badge)$/i;
    if (atomPatterns.test(name) && !content.includes('import')?.length > 3) {
      this.result.byLevel.atoms.push(comp.name);
      return;
    }
    
    // Molecules: composed of multiple elements
    const moleculePatterns = /^(formfield|searchbar|navbar|card|modal|dropdown|toast|alert|listitem|menuitem)$/i;
    if (moleculePatterns.test(name)) {
      this.result.byLevel.molecules.push(comp.name);
      return;
    }
    
    // Organisms: complex sections
    const organismPatterns = /^(header|footer|hero|sidebar|navigation|gallery|table|chart|dashboard)$/i;
    if (organismPatterns.test(name)) {
      this.result.byLevel.organisms.push(comp.name);
      return;
    }
    
    // Pages: route components
    const pagePatterns = /^(page|route|screen|home|about|contact|login|register|dashboard)$/i;
    if (pagePatterns.test(name) || comp.relativePath.includes('/pages/')) {
      this.result.byLevel.pages.push(comp.name);
      return;
    }
    
    // Templates: layout wrappers
    const templatePatterns = /^(layout|template|wrapper|shell|master)$/i;
    if (templatePatterns.test(name)) {
      this.result.byLevel.templates.push(comp.name);
      return;
    }
    
    this.result.byLevel.unknown.push(comp.name);
  }

  identifyBaseComponents() {
    const basePatterns = {
      buttons: /^(Button|Btn|ActionButton|IconButton|SubmitButton|GhostButton)$/i,
      inputs: /^(Input|TextField|TextInput|FormInput|NumberInput|PasswordInput|EmailInput)$/i,
      selects: /^(Select|Dropdown|SelectField|MultiSelect|Autocomplete|Combobox)$/i,
      textareas: /^(Textarea|TextArea|TextField|LongTextInput|MessageInput)$/i,
      labels: /^(Label|FormLabel|FieldLabel|InputLabel)$/i,
      checkboxes: /^(Checkbox|CheckBox|Check|Toggle|Switch)$/i,
      radios: /^(Radio|RadioButton|RadioGroup|RadioInput)$/i,
      switches: /^(Switch|Toggle|Toggler)$/i
    };

    for (const comp of this.components) {
      for (const [category, pattern] of Object.entries(basePatterns)) {
        if (pattern.test(comp.name)) {
          this.result.baseComponents[category].push({
            name: comp.name,
            path: comp.relativePath,
            props: this.extractProps(comp)
          });
        }
      }
    }
  }

  extractProps(comp) {
    const props = [];
    const content = comp.content;
    
    if (comp.extension.match(/\.jsx?$/)) {
      // React props detection
      const propMatches = content.match(/\{([\w,\s]+)\}/g);
      if (propMatches) {
        propMatches.forEach(match => {
          const clean = match.replace(/[{}\s]/g, '').split(',').filter(Boolean);
          props.push(...clean);
        });
      }
      
      // TypeScript interface
      const interfaceMatch = content.match(/interface\s+Props\s*\{([^}]+)\}/s);
      if (interfaceMatch) {
        const lines = interfaceMatch[1].split('\n');
        lines.forEach(line => {
          const prop = line.match(/(\w+)\s*\??\s*:/);
          if (prop) props.push(prop[1]);
        });
      }
    }
    
    if (comp.extension === '.vue') {
      // Vue props
      const propsMatch = content.match(/props\s*:\s*\[([^\]]+)\]/);
      if (propsMatch) {
        const arr = propsMatch[1].match(/['"]([^'"]+)['"]/g);
        if (arr) props.push(...arr.map(p => p.replace(/['"]/g, '')));
      }
      
      const definePropsMatch = content.match(/defineProps\s*\(\s*\{([^}]+)\}/);
      if (definePropsMatch) {
        const obj = definePropsMatch[1].match(/(\w+)\s*:/g);
        if (obj) props.push(...obj.map(p => p.replace(':', '')));
      }
    }
    
    return [...new Set(props)].slice(0, 10); // Limit to 10 unique props
  }

  buildDependencyGraph() {
    const graph = {};
    
    for (const comp of this.components) {
      graph[comp.name] = {
        imports: [],
        importedBy: []
      };
      
      // Find imports
      const importMatches = comp.content.match(/import\s+\w+\s+from\s+['"]([^'"]+)['"]/g);
      if (importMatches) {
        importMatches.forEach(imp => {
          const source = imp.match(/from\s+['"]([^'"]+)['"]/)[1];
          const importedName = imp.match(/import\s+(\w+)/)[1];
          
          // Check if import is a local component
          const isLocal = !source.includes('node_modules') && 
                         (source.startsWith('.') || source.startsWith('@/') || source.startsWith('~/'));
          
          if (isLocal) {
            graph[comp.name].imports.push({
              name: importedName,
              source
            });
          }
        });
      }
    }
    
    // Build reverse graph (importedBy)
    for (const [compName, data] of Object.entries(graph)) {
      for (const imp of data.imports) {
        if (graph[imp.name]) {
          graph[imp.name].importedBy.push(compName);
        }
      }
    }
    
    this.result.componentGraph = graph;
  }

  findMostReused() {
    const usage = {};
    
    for (const [compName, data] of Object.entries(this.result.componentGraph)) {
      usage[compName] = data.importedBy.length;
    }
    
    this.result.mostReused = Object.entries(usage)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([name, count]) => ({ name, usedBy: count }));
  }
}

// CLI execution
if (require.main === module) {
  const projectPath = process.argv[2] || process.cwd();
  const detector = new ComponentTreeDetector(projectPath);
  detector.detect().then(result => {
    console.log(JSON.stringify(result, null, 2));
  });
}

module.exports = ComponentTreeDetector;
