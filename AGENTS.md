# Project Skills Registry

This file registers all project-specific skills available in this repository.

## Available Skills

### skill-frontend-design-scanner
- **Path:** `skill-frontend-design-scanner/SKILL.md`
- **Trigger:** scan design system, detect CSS architecture, analyze frontend tokens, detect Tailwind, BEM, Atomic Design
- **Description:** Scan projects for design system patterns, component trees, and branding tokens. Based on FAANG research (Meta StyleX, Google Material, Amazon Style Dictionary).
- **Assets:**
  - `assets/detect-tailwind.js` - Tailwind CSS detection and parsing
  - `assets/detect-css-architecture.js` - CSS methodology detection (BEM, Atomic, SMACSS, ITCSS)
  - `assets/detect-component-tree.js` - Component hierarchy and base component detection
  - `assets/extract-tokens.js` - Token extraction from CSS/SCSS/JSX/Vue
  - `assets/detect-css-in-js.js` - CSS-in-JS library detection (styled-components, Emotion, StyleX)
  - `assets/token-schema.json` - Standardized token output schema
- **References:**
  - `references/architectures.md` - CSS architecture patterns reference
  - `references/tailwind-detection.md` - Tailwind-specific detection patterns
  - `references/faang-patterns.md` - FAANG design system patterns and detection algorithms

### skill-cd-ci-ddd-score-validation
- **Path:** `skill-cd-ci-ddd-score-validation/SKILL.md`

### skill-clean-architecture
- **Path:** `skill-clean-architecture/SKILL.md`

### skill-design-elite
- **Path:** `skill-design-elite/SKILL.md`

### skill-prevention-layer
- **Path:** `skill-prevention-layer/SKILL.md`

### skill-prisma-mongo-audit
- **Path:** `skill-prisma-mongo-audit/SKILL.md`

### skill-spec-product
- **Path:** `skill-spec-product/SKILL.md`

### skill-style-css-clean
- **Path:** `skill-style-css-clean/SKILL.md`

## Usage

To use any skill, reference it in your agent configuration or include the skill path in your prompt.

## Adding New Skills

Follow the skill-creator guidelines when adding new skills to this project.
