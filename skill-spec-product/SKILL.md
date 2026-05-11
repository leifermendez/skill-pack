---
name: skill-spec-product
description: >-
  Generador de especificaciones de producto en YAML. Unico proposito: crear,
  estructurar y validar archivos .yml de historias de usuario. No edita codigo
  fuente.
compatibility: Framework agnostic. Works with any tech stack or team structure.
metadata:
  author: leifermendez
  version: "4.0.0"
  tags: "product, spec-driven, user-stories, requirements, product-management, delivery, handoff"
---

# skill-spec-product

PROPOSITO UNICO DE ESTE SKILL: Crear, generar y validar archivos YAML de especificacion de producto.
Este skill NO edita, modifica, compila ni genera codigo fuente. Su unico entregable son archivos .yml.

Product Spec-Driven Delivery is a requirements-first workflow where YAML user stories are the single source of truth for product teams. Every feature request traces back to a spec. Every acceptance criterion is verifiable. Every handoff to engineering is complete.

This skill guides product teams through a 5-phase process from raw intake to a validated handoff package. The output of every phase is a set of structured YAML files.

---

## The 5 Phases

| Phase | Name | Tracker / Milestone | Deliverable |
|---|---|---|---|
| **01** | Discovery & Intake | Requirements Package Complete | Spec folders in `spec-product/`, Stakeholder Map |
| **02** | Prioritization | Roadmap Defined | Prioritized backlog (RICE/WSJF), Quarter roadmap |
| **03** | Specification | Specs Ready for Review | Detailed user stories with acceptance criteria, flows, metrics |
| **04** | Validation | Stakeholder Sign-Off | Approved specs, risk assessment, go/no-go decision |
| **05** | Handoff Package | Engineering Ready | Complete delivery package: specs, context, success criteria |

**Rule:** Do not begin a phase until the previous phase's `Exit Criteria` are fully satisfied. The agent executing this skill must verify the checklist before advancing.

---

## Pre-flight Check

Before starting any phase, run the spec validator and inspect the project root:

```bash
bash references/validate-specs.sh
```

1. The validator checks if `spec-product/` exists and creates it if missing.
2. If it exists:
   - Lists all subdirectories: `feat-XXXX-dd-mm-yy-hh-mm/`
   - Identifies the most recent by directory name timestamp
   - Reads the `feat-XXXX.yml` inside the most recent folder for context
   - Records the highest sequential ID to continue numbering from there
3. Validate: no gaps in ID sequence unless explicitly documented.

---

## Spec Folder & File Naming Convention

**Folder Format:** `spec-product/feat-XXXX-dd-mm-yy-hh-mm/`

- `XXXX`: Sequential 4-digit number (0001, 0002, ...). No gaps allowed.
- `dd-mm-yy-hh-mm`: Creation timestamp. 2-digit year.
- Example: `spec-product/feat-0001-15-05-26-14-30/`

**File Format (inside folder):** `feat-XXXX.yml`

- Only the ID. No timestamp, no descriptive slug.
- One file per folder. No additional files.
- Example: `spec-product/feat-0001-15-05-26-14-30/feat-0001.yml`

---

## Post-phase Verification

After completing any phase, run the spec validator:

```bash
bash references/validate-specs.sh
```

Then verify manually:

1. List all `spec-product/feat-*/` directories created in this phase.
2. For each directory, verify:
   - [ ] Directory name follows `feat-XXXX-dd-mm-yy-hh-mm/` format
   - [ ] Directory contains exactly one file: `feat-XXXX.yml`
   - [ ] YAML file is valid and non-empty
   - [ ] YAML has required fields: id, type, as_a, i_want, so_that, product, metadata.created_at
   - [ ] `metadata.created_at` matches the directory timestamp (dd-mm-yy-hh-mm)
   - [ ] ID in YAML matches ID in directory name
3. If any check fails:
   - Do NOT proceed to the next phase
   - Report the exact failure
   - Fix before continuing

---

## Final Verification

After Phase 05 complete:

1. Inventory all `spec-product/feat-*/` directories.
2. Verify no orphaned IDs (gaps in sequence without documented reason).
3. Verify all P0/P1 stories have status `approved` or `done`.
4. Verify timestamps in directory names are chronologically ordered by ID.
5. Emit summary:
   - Total specs created
   - P0 count / P1 count / P2+P3 count
   - Timestamp range (first → last)
   - Coverage % of acceptance criteria

---

## Quick Start

1. Run **Pre-flight Check** above.
2. Load `references/phase-01-discovery-and-intake.md` and collect requirements.
3. When `Exit Criteria` pass, run **Post-phase Verification**, then load `references/phase-02-prioritization.md`.
4. Continue sequentially through all 5 phases, running **Post-phase Verification** after each.
5. After Phase 05, run **Final Verification**.

---

## Phases

- [Phase 01: Discovery & Intake](references/phase-01-discovery-and-intake.md)
- [Phase 02: Prioritization](references/phase-02-prioritization.md)
- [Phase 03: Specification](references/phase-03-specification.md)
- [Phase 04: Validation](references/phase-04-validation.md)
- [Phase 05: Handoff Package](references/phase-05-handoff-package.md)

---

## References

- [Risk Matrix](references/risk-matrix.md) - Risk identification & mitigation
- [Tools](references/tools.md) - Recommended software per phase
- [Books](references/books.md) - Essential reading for product managers
- [Spec Validator](references/validate-specs.sh) - Bash script to validate `spec-product/` structure and YAML contents
- [User Story Templates README](references/user-story-templates-README.md) - YAML schema & examples
  - [Discovery Template](references/feat-001-discovery.yml)
  - [Feature Template](references/feat-002-user-registration.yml)
  - [Pain Point Template](references/feat-003-manual-invoicing.yml)

---

## Core Principles

1. **Este skill genera specs en YAML** - No implementa features, no escribe codigo, no crea branches ni hace deploys. Su unico output son archivos .yml.
2. **Specs are the contract** - YAML user stories are the agreement between product and engineering.
3. **Traceability** - Every spec has an ID that follows the feature through design, development, and release.
4. **Acceptance criteria are non-negotiable** - If it cannot be verified, it is not a criterion.
5. **Start with the problem, not the solution** - Specs must articulate the user need before proposing features.
6. **Decisions are documented** - Priority changes, scope cuts, and trade-offs are recorded.
7. **Handoff is a package, not a meeting** - Engineering receives complete context, not a bullet list.

---

**Build YAML specs that serve as the unambiguous contract between product and engineering.**
