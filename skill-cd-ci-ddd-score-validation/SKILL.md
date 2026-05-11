---
name: skill-cd-ci-ddd-score-validation
description: >-
  Auditor of Clean Architecture + Domain-Driven Design (DDD) layer ordering.
  The LLM agent performs the audit; companion shell scripts provide raw structured data.
  Output: YAML report with score [0-5] and actionable todo_desirable list.
  Designed for GitHub Actions and manual agent invocation.
compatibility: Multi-language. Works with TypeScript/JavaScript, Java, Python, PHP, Go, C#, and others.
metadata:
  author: leifermendez
  version: "1.0"
  tags: "clean-architecture, ddd, ci-cd, validation, scoring, yaml"
---

## 1. Purpose

Audit any codebase to verify that Clean Architecture / DDD layer ordering is respected:

```
Domain <- Application <- UseCases <- Infrastructure
Domain <- Application <- Interface
```

The agent (LLM) is the primary auditor. Companion shell scripts in `tools/` extract raw data (file lists, imports, dependency graph). The agent interprets this data, applies subjective criteria, computes a score, and writes the final YAML report.

## 2. When to Use

- New project onboarding: assess architecture health.
- Pre-refactoring: identify violations before restructuring.
- CI/CD gate: generate a score report on every PR.
- Code review: validate that changes respect layer boundaries.

## 3. Workflow (7 Steps)

### Step 1: Discover Source Root
Invoke: `bash tools/discover-source.sh <project_path>`
Purpose: find the main source folder (`src/`, `source/`, `app/`, `lib/`, etc.).

### Step 2: Discover Layers
Invoke: `bash tools/discover-layers.sh <source_root>`
Purpose: map which layer folders exist inside the source root.

### Step 3: Classify Files
Invoke: `bash tools/classify-files.sh <source_root>`
Purpose: classify every file by layer, language, and responsibility type.

### Step 4: Extract Imports
Invoke: `bash tools/extract-imports.sh <classified_files_yaml>`
Purpose: build a dependency graph (imports per file).

### Step 5: Validate Hard Rules
Invoke:
- `bash tools/validate-dependencies.sh <imports_yaml> <layers_yaml>`
- `bash tools/validate-naming.sh <classified_files_yaml>`
- `bash tools/detect-logic-leaks.sh <classified_files_yaml>`

Purpose: obtain objective, machine-detectable violations.

### Step 6: Apply Subjective Audit (LLM)
The agent reads key files directly (using its own Read/Glob capabilities) to evaluate:
- Are DTOs flat in the Application layer?
- Is there one responsibility per file?
- Are LAYER header comments present?
- Are repository interfaces defined in Domain?
- Does the Dependency Inversion principle hold in practice?

The agent combines:
- Hard violations (weight ~70%)
- Subjective findings (weight ~30%)
- Scoring matrix from `references/scoring-matrix.md`

### Step 7: Generate Final YAML Report
The agent writes `ddd-score-report.yml` with exact schema defined in `references/output-schema.yml`.

## 4. Tool Invocation Guide

All scripts are **100% bash**, read from the filesystem, and write **YAML to stdout**.

### 4.1 discover-source.sh
```bash
bash tools/discover-source.sh /path/to/project
```
**Output:**
```yaml
project_path: /path/to/project
source_root: /path/to/project/src
candidates:
  - path: src
    file_count: 142
    languages:
      - typescript
      - javascript
  - path: app
    file_count: 12
    languages:
      - typescript
selected_reason: highest file count
```

### 4.2 discover-layers.sh
```bash
bash tools/discover-layers.sh /path/to/project/src
```
**Output:**
```yaml
source_root: /path/to/project/src
layers_detected:
  - name: Domain
    path: src/domain
    file_count: 12
  - name: Application
    path: src/application
    file_count: 8
  - name: Infrastructure
    path: src/infrastructure
    file_count: 6
  - name: Interface
    path: src/interface
    file_count: 4
```

### 4.3 classify-files.sh
```bash
bash tools/classify-files.sh /path/to/project/src
```
**Output:**
```yaml
source_root: /path/to/project/src
files:
  - path: src/domain/entities/user.entity.ts
    layer: Domain
    language: typescript
    type: entity
    basename: user.entity.ts
  - path: src/application/use-cases/create-user.use-case.ts
    layer: Application
    language: typescript
    type: use-case
    basename: create-user.use-case.ts
```

### 4.4 extract-imports.sh
```bash
bash tools/extract-imports.sh /path/to/classified-files.yml
```
**Output:**
```yaml
imports:
  - source_file: src/application/use-cases/create-user.use-case.ts
    imported_path: ../../domain/entities/user.entity
    is_relative: true
    import_line: "import { User } from '../../domain/entities/user.entity';"
    language: typescript
```

### 4.5 validate-dependencies.sh
```bash
bash tools/validate-dependencies.sh /path/to/imports.yml /path/to/layers.yml
```
**Output:**
```yaml
violations:
  - file: src/domain/entities/user.entity.ts
    rule: DOMAIN_NO_EXTERNAL_DEPS
    severity: critical
    message: Domain entity imports from Infrastructure
    suggestion: "Move 'import { PrismaClient }' from src/domain/entities/user.entity.ts to an Infrastructure repository implementation."
    imported_layer: Infrastructure
    source_layer: Domain
```

### 4.6 validate-naming.sh
```bash
bash tools/validate-naming.sh /path/to/classified-files.yml
```
**Output:**
```yaml
naming_issues:
  - file: src/application/createUser.ts
    layer: Application
    expected_pattern: "*.use-case.ts"
    actual: createUser.ts
    severity: medium
    suggestion: "Rename to create-user.use-case.ts"
```

### 4.7 detect-logic-leaks.sh
```bash
bash tools/detect-logic-leaks.sh /path/to/classified-files.yml
```
**Output:**
```yaml
logic_leaks:
  - file: src/interface/controllers/user.controller.ts
    layer: Interface
    keyword_found: calculateTax
    context_line: "const tax = calculateTax(amount, rate);"
    severity: high
    suggestion: "Move business logic to a Domain Service or Application Use Case."
```

### 4.8 aggregate-raw-data.sh (Convenience)
```bash
bash tools/aggregate-raw-data.sh /path/to/project
```
Runs steps 1-7 in sequence and emits a combined YAML document.

## 5. Hard Rules Reference

Rules validated automatically by scripts or enforced by the agent:

| Rule | Layer | Requirement |
|---|---|---|
| `DOMAIN_NO_EXTERNAL_DEPS` | Domain | Zero external dependencies. No frameworks, no DB, no imports from outer layers. |
| `APPLICATION_ONLY_DOMAIN` | Application | May only import from Domain. No frameworks, no direct DB access. |
| `USECASES_ONLY_INNER` | UseCases | May only import Domain and/or Application. |
| `INFRASTRUCTURE_NO_INTERFACE` | Infrastructure | Must not import from Interface. May import Domain and Application. |
| `INTERFACE_ONLY_APPLICATION` | Interface | May only import from Application. No direct Domain or Infrastructure access. |
| `NO_CIRCULAR_DEPENDENCIES` | All | No cycle between layers. |
| `REPOSITORY_INTERFACE_IN_DOMAIN` | Domain | Repository interfaces (ports) must live in Domain. |
| `REPOSITORY_IMPL_IN_INFRA` | Infrastructure | Repository implementations must live in Infrastructure. |
| `NAMING_CONVENTION` | All | Files should follow layer-specific naming patterns (kebab-case preferred). |
| `ONE_RESPONSIBILITY_PER_FILE` | All | One class / interface / function per file. |

## 6. Subjective Criteria (Agent Evaluation)

The agent must read files and judge:

- **DTO quality**: Are Application DTOs flat objects without ORM annotations?
- **Header comments**: Does every file start with a `LAYER:` documentation comment?
- **Business logic placement**: Is there business logic hidden in controllers, DTOs, or mappers?
- **Dependency inversion**: Are dependencies injected via constructor (or simple composition root) rather than instantiated directly?
- **Anemic domain model**: Do entities contain behavior, or are they just data bags?
- **Use case purity**: Do use cases only orchestrate, or do they contain business rules?

## 7. Scoring Matrix

Score is computed by the agent using `references/scoring-matrix.md`.

Quick reference:

| Score | Meaning |
|---|---|
| **5** | Excellent. All hard rules pass. Naming consistent. Zero subjective issues. |
| **4** | Good. All hard rules pass. Minor subjective issues (missing headers, small naming gaps). |
| **3** | Fair. Core hard rules OK. Missing documented layers or naming inconsistencies. |
| **2** | Poor. Significant dependency violations (Domain imports Infra, Controller calls DB). |
| **1** | Bad. Layer structure barely exists. Naming conventions largely ignored. |
| **0** | No attempt. No Clean Architecture / DDD structure detectable. |

## 8. YAML Output Specification

The agent must generate a file matching `references/output-schema.yml`.

Mandatory top-level keys:
- `project`
- `score`
- `max_score`
- `summary` (human-readable paragraph)
- `layers_detected[]`
- `violations[]` (each with `suggestion` for concrete auto-fix)
- `subjective_notes[]`
- `todo_desirable[]` (each with `priority`: P0/P1/P2, `layer`, `task`)

## 9. Todo Templates

For inspiration generating `todo_desirable`, see `references/todo-templates.md`.

## 10. CI/CD Usage

```bash
# 1. Extract raw data
bash tools/aggregate-raw-data.sh . > /tmp/raw-audit.yml

# 2. Agent reads raw-audit.yml + source files
# 3. Agent writes ddd-score-report.yml
```

In GitHub Actions, steps 2-3 are performed by the agent/LLM step after the raw data is extracted.

---

> **Build specs that engineering can execute without asking "what did you mean?"**
