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

### skill-performance-audit
- **Path:** `skill-performance-audit/SKILL.md`
- **Trigger:** performance audit, bottleneck detection, N+1 queries, slow queries, bundle bloat, missing indexes, render thrashing, optimize performance
- **Description:** Scans backend, frontend, and database layers for observable performance anti-patterns. Produces a severity-ranked audit report (CRITICAL / WARNING / NOTICE) with before/after code fixes for the top bottlenecks found.
- **References:**
  - `references/backend-bottlenecks.md` - N+1 queries, blocking I/O, pagination, caching patterns
  - `references/frontend-bottlenecks.md` - Memoization, lazy loading, bundle optimization, image best practices
  - `references/database-bottlenecks.md` - Indexing strategies, query optimization, transactions

### skill-dead-code-legacy
- **Path:** `skill-dead-code-legacy/SKILL.md`
- **Trigger:** dead code, unused exports, legacy code, deprecated APIs, orphaned code, technical debt, zombie routes, unused dependencies, commented-out code, TODO cleanup
- **Description:** Detects unused exports, unreachable code, zombie routes, orphaned test files, unused dependencies, deprecated API usage, outdated language idioms, and accumulated technical debt markers. Produces a three-tier severity report (REMOVE NOW / REVIEW & CLEAN / TECHNICAL DEBT) with safe removal guidance.
- **References:**
  - `references/dead-code-patterns.md` - Unused exports, unreachable code, zombie routes, orphaned tests, feature flags
  - `references/legacy-patterns.md` - Deprecated React/Node.js APIs, old JS/Python idioms, outdated dependencies
  - `references/tech-debt-signals.md` - TODO/FIXME taxonomy, commented-out code, duplication detection

### skill-security-checklist
- **Path:** `skill-security-checklist/SKILL.md`
- **Trigger:** security audit, codebase review, technical debt assessment, architecture analysis
- **Description:** Comprehensive audit of any codebase detecting frameworks, languages, architecture patterns, and pain points with pros/cons tables.
- **Assets:**
  - `assets/audit-template.md` - Base template for the final markdown report
  - `assets/detect-stack.sh` - Detect languages, frameworks, and dependencies
  - `assets/detect-architecture.sh` - Identify architecture patterns (DDD, MVC, Hexagonal, etc.)
  - `assets/detect-infrastructure.sh` - Detect Docker, K8s, CI/CD, cloud infrastructure
  - `assets/analyze-complexity.sh` - Measure cyclomatic complexity, file/function length, duplication
  - `assets/detect-security-risks.sh` - Scan for hardcoded secrets, SQL injection, XSS, insecure deps
  - `assets/assess-tech-debt.sh` - Find TODOs, deprecated deps, missing tests, documentation gaps
  - `assets/generate-audit-report.sh` - Aggregate all data into a single markdown report
- **References:**
  - `references/architecture-patterns.md` - Reference guide for architecture pattern detection
  - `references/code-smells.md` - Catalog of code smells and anti-patterns
  - `references/complexity-metrics.md` - Thresholds and interpretation for complexity metrics
  - `references/security-checklist.md` - Comprehensive security checks and mitigation strategies

## Usage

To use any skill, reference it in your agent configuration or include the skill path in your prompt.

## Adding New Skills

Follow the skill-creator guidelines when adding new skills to this project.
