---
name: skill-spec-product
description: >-
  Product Spec-Driven Delivery framework. A requirements-first workflow where
  YAML user stories are the single source of truth for product teams.
  Guides product managers from raw intake to a validated handoff package
  ready for engineering execution.
compatibility: Framework agnostic. Works with any tech stack or team structure.
metadata:
  author: leifermendez
  version: "3.0.0"
  tags: "product, spec-driven, user-stories, requirements, product-management, delivery, handoff"
---

# skill-spec-product

Product Spec-Driven Delivery is a requirements-first workflow where YAML user stories are the single source of truth for product teams. Every feature request traces back to a spec. Every acceptance criterion is verifiable. Every handoff to engineering is complete.

This skill guides product teams through a 5-phase process from raw intake to a validated handoff package.

---

## The 5 Phases

| Phase | Name | Tracker / Milestone | Deliverable |
|---|---|---|---|
| **01** | Discovery & Intake | Requirements Package Complete | User Story YAMLs, Stakeholder Map |
| **02** | Prioritization | Roadmap Defined | Prioritized backlog (RICE/WSJF), Quarter roadmap |
| **03** | Specification | Specs Ready for Review | Detailed user stories with acceptance criteria, flows, metrics |
| **04** | Validation | Stakeholder Sign-Off | Approved specs, risk assessment, go/no-go decision |
| **05** | Handoff Package | Engineering Ready | Complete delivery package: specs, context, success criteria |

**Rule:** Do not begin a phase until the previous phase's `Exit Criteria` are fully satisfied. The agent executing this skill must verify the checklist before advancing.

---

## Quick Start

1. Load `references/phase-01-discovery-and-intake.md` and collect requirements.
2. When `Exit Criteria` pass, load `references/phase-02-prioritization.md`.
3. Continue sequentially through all 5 phases.

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
- [User Story Templates README](references/user-story-templates-README.md) - YAML schema & examples
  - [Discovery Template](references/feat-001-discovery.yml)
  - [Feature Template](references/feat-002-user-registration.yml)
  - [Pain Point Template](references/feat-003-manual-invoicing.yml)

---

## Core Principles

1. **Specs are the contract** - YAML user stories are the agreement between product and engineering.
2. **Traceability** - Every spec has an ID that follows the feature through design, development, and release.
3. **Acceptance criteria are non-negotiable** - If it cannot be verified, it is not a criterion.
4. **Start with the problem, not the solution** - Specs must articulate the user need before proposing features.
5. **Decisions are documented** - Priority changes, scope cuts, and trade-offs are recorded.
6. **Handoff is a package, not a meeting** - Engineering receives complete context, not a bullet list.

---

**Build specs that engineering can execute without asking "what did you mean?"**
