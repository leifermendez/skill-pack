# Phase 04: Validation

## Objective

Secure stakeholder sign-off and verify that specs are complete, consistent, and ready for engineering. This is the quality gate before handoff.

## Input Required

- Specified spec folders from `spec-product/` (status `ready` or `in-review`)
- Quarter roadmap
- Stakeholder map

---

## Steps

### Step 4.1: Stakeholder Review

Conduct a structured review with each stakeholder group.

```
REVIEW CHECKLIST BY ROLE

Product Leadership
  [ ] Problem statement is clear and strategic
  [ ] Success metrics align with quarterly goals
  [ ] Priority (P0-P3) is justified

Design
  [ ] User flows are complete
  [ ] Mockups or wireframes are linked
  [ ] Edge cases and empty states are covered

Engineering Lead
  [ ] Acceptance criteria are technically verifiable
  [ ] Dependencies are identified and scheduled
  [ ] Complexity estimate is realistic
  [ ] Risks have mitigation plans

QA / Testing
  [ ] Each acceptance criterion can be tested
  [ ] Error paths are specified
  [ ] Test data requirements are noted

Legal / Compliance / Security
  [ ] Regulatory requirements are addressed
  [ ] Data handling is documented
  [ ] User consent or permissions are specified (if applicable)
```

### Step 4.2: Consistency Check

Verify that specs do not contradict each other.

```
CONSISTENCY AUDIT

Story A: feat-0002
  Says: "User can change email without re-verification"

Story B: feat-0008
  Says: "All email changes require re-verification"

CONFLICT DETECTED
Resolution: [Update one story or clarify the boundary]
```

### Step 4.3: Risk Assessment

Document remaining risks before committing engineering resources.

```
RISK REGISTER (Pre-Handoff)

ID    │ Risk Description          │ Probability │ Impact │ Response │ Owner
──────┼───────────────────────────┼─────────────┼────────┼──────────┼──────
R-001 │ [Technical uncertainty]   │ Medium      │ High   │ Mitigate │ Eng
R-002 │ [Stakeholder disagreement]│ Low       │ Medium │ Monitor  │ PM
```

### Step 4.4: Go / No-Go Decision

For every P0 story, a formal decision is required.

```
GO / NO-GO TEMPLATE

Story: feat-XXXX [Name]

Criteria Met:
  [ ] Problem statement validated
  [ ] Acceptance criteria complete and testable
  [ ] Success metrics defined
  [ ] Dependencies resolved
  [ ] Risks accepted or mitigated
  [ ] Stakeholder sign-off obtained

Decision: [GO / NO-GO / CONDITIONAL GO]
Conditions (if conditional): [What must happen before engineering starts]

Signed by:
  Product: _______________ Date: _______
  Engineering: ___________ Date: _______
  (Others as needed)
```

---

## Expected Output

- Completed review checklists per stakeholder group
- Consistency audit with conflicts resolved
- Risk register with owners and response plans
- Go / No-Go decisions for all P0 stories
- Story statuses updated to `approved`
- All `spec-product/feat-*/` folders verified: naming convention intact, one file per folder, timestamps match

---

## Exit Criteria

- [ ] All P0 stories have stakeholder sign-off
- [ ] All P1 stories scheduled for the quarter are reviewed
- [ ] No unresolved consistency conflicts between stories
- [ ] Risk register created with P0/P1 risks assigned to owners
- [ ] Go / No-Go decisions documented
- [ ] Story statuses updated to `approved`
- [ ] Engineering lead has acknowledged readiness to receive handoff
- [ ] All spec folders follow naming convention: `feat-XXXX-dd-mm-yy-hh-mm/`
- [ ] Each folder contains exactly one file: `feat-XXXX.yml`
- [ ] `metadata.updated_at` timestamp updated on modified specs

---

## Rollback / Reprocess Rules

If a story receives NO-GO:
1. Move it back to Phase 03 for rework.
2. Document the specific gap that caused the rejection.
3. Update the YAML with the required changes.
4. Re-run Phase 04 validation before attempting handoff again.

If a spec folder naming convention is violated:
1. Rename the folder to `feat-XXXX-dd-mm-yy-hh-mm/` format.
2. Rename the file inside to `feat-XXXX.yml`.
3. Update any cross-references.
4. Re-verify before proceeding.
