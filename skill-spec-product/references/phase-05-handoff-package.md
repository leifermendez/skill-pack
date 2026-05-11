# Phase 05: Handoff Package

## Objective

ALCANCE DE ESTA FASE: Documentar el paquete de entrega como contenido estructurado en YAML y documentos de referencia.
Este skill NO realiza kickoffs con ingenieria, NO crea tickets en Jira/Linear, NO genera documentos fuera de `spec-product/`, y NO escribe codigo.

Assemble everything engineering needs to start building — in one place, with full context. The handoff is a package, not a meeting.

## Input Required

- Validated, `approved` spec folders from `spec-product/`
- Review checklists and risk register from Phase 04
- Quarter roadmap

---

## Steps

### Step 5.1: Package Assembly

Create a master handoff document that references all specs.

```
HANDOFF PACKAGE

Initiative: [Name]
Quarter: [Q1 / Q2 / Q3 / Q4]
Prepared by: [PM Name]
Date: [YYYY-MM-DD]

---

STORIES INCLUDED

| ID         | Title                 | Priority | Complexity | Status    │
|------------|-----------------------|----------|------------|-----------|
| feat-0002  │ [Title]               │ P0       │ Medium     │ Approved  │
| feat-0003  │ [Title]               │ P0       │ High       │ Approved  │
| feat-0005  │ [Title]               │ P1       │ Low        │ Approved  │

---

DEPENDENCIES

| Story     │ Depends On │ Scheduled │ Risk │
|-----------|------------|-----------|------|
| ...       │ ...        │ ...       │ ...  │

---

SUCCESS CRITERIA (Initiative Level)

- [Metric 1]: [Target]
- [Metric 2]: [Target]

---

RISKS & MITIGATIONS

| ID │ Risk │ Owner │ Response │
|----|------|-------|----------|
| ...│ ...  │ ...   │ ...      │

---

SUPPORTING MATERIALS

- Figma mockups: [Link]
- User research: [Link]
- Analytics baseline: [Link]
- Previous related specs: [Links]
```

### Step 5.2: Engineering Context Document

Beyond the YAMLs, provide narrative context that specs cannot capture.

```
ENGINEERING CONTEXT

Background:
  [Why are we building this now? What strategic goal does it serve?]

User Context:
  [Who are the users? What is their current pain?]

Business Context:
  [What revenue, cost, or efficiency impact is expected?]

Technical Context:
  [Are there existing systems, APIs, or constraints engineering should know?]

Open Questions:
  [What is intentionally left for engineering to decide?]

Out of Scope:
  [What is explicitly NOT included in this initiative?]

Definition of Done:
  [What does "complete" mean for this initiative?]
```

### Step 5.3: Spec Traceability Setup

Ensure every spec can be tracked from handoff to release.

```
TRACEABILITY MATRIX

Story ID     │ Handoff Date │ Eng Ticket │ Design Ticket │ QA Ticket │ Release │ Status
─────────────┼──────────────┼────────────┼───────────────┼───────────┼─────────┼────────
feat-0002    │ 2024-02-01   │ PROJ-123   │ DES-456       │ QA-789    │ v2.3.0  │ Done
```

### Step 5.4: Kickoff Briefing

Schedule a single kickoff session with engineering, design, and QA.

```
KICKOFF AGENDA (30-45 minutes)

1. Problem & Goal (5 min)
   - Why this initiative matters
   - Success metrics

2. Story Walkthrough (15 min)
   - Walk through each P0 story
   - Highlight edge cases and acceptance criteria
   - Clarify open questions

3. Dependencies & Risks (5 min)
   - What is blocked on what
   - Known risks and mitigations

4. Logistics (5 min)
   - Sprint schedule
   - Review cadence
   - Point of contact for questions

5. Q&A (10 min)
   - Engineering asks clarifying questions
   - PM documents answers and updates specs if needed
```

**Rule:** If engineering asks a question that reveals a spec gap, update the YAML immediately and distribute the updated version.

---

## Expected Output

- Handoff package document
- Engineering context document
- Traceability matrix
- Kickoff session completed
- Updated spec statuses (if any gaps were found during kickoff)
- All `spec-product/feat-*/` folders verified: naming convention intact, one file per folder, timestamps match

---

## Exit Criteria

- [ ] Handoff package assembled with all P0/P1 stories included
- [ ] Engineering context document written
- [ ] Traceability matrix created
- [ ] Kickoff session held with engineering, design, and QA
- [ ] No open questions remain that block engineering start
- [ ] Story statuses updated to `done` (from a product perspective)
- [ ] Engineering has confirmed they have everything needed to begin
- [ ] All spec folders follow naming convention: `feat-XXXX-dd-mm-yy-hh-mm/`
- [ ] Each folder contains exactly one file: `feat-XXXX.yml`
- [ ] `metadata.updated_at` timestamp updated on modified specs

---

## Rollback / Reprocess Rules

If engineering identifies a blocker during kickoff:
1. Pause the handoff.
2. Document the blocker and whether it requires spec changes, design changes, or architectural discussion.
3. Update the relevant YAML or context document.
4. Re-convene only when the blocker is resolved.

If a spec folder naming convention is violated:
1. Rename the folder to `feat-XXXX-dd-mm-yy-hh-mm/` format.
2. Rename the file inside to `feat-XXXX.yml`.
3. Update any cross-references.
4. Re-verify before proceeding.
