# Phase 03: Specification

## Objective

PROPOSITO DE ESTA FASE: Completar los campos del archivo YAML (acceptance criteria, product metadata, technical context, business value).
No escribir codigo de implementacion, no crear mocks funcionales, no generar scripts.

Produce detailed, unambiguous user stories that engineering can execute without asking clarifying questions. The spec is the contract.

## Input Required

- Prioritized spec folders from `spec-product/`
- Quarter roadmap from Phase 02
- Any existing design assets, flows, or research

---

## Steps

### Step 3.1: Story Refinement

For each story moving into specification, validate the user story statement:

```
USER STORY VALIDATION

As a [specific user role]
I want [specific action or capability]
So that [observable benefit or outcome]

Checks:
[ ] Role is specific (not "user" — which user?)
[ ] Action is observable (can you see it happening?)
[ ] Outcome is measurable (can you verify it happened?)
```

### Step 3.2: Acceptance Criteria

Write acceptance criteria using **Given / When / Then** for every scenario.

```
ACCEPTANCE CRITERIA TEMPLATE

ID: ac-01
Given: [A specific precondition or starting state]
When: [A specific action is taken]
Then: [An observable, verifiable result occurs]

Quality Checks:
[ ] Each criterion is independently verifiable
[ ] No ambiguity ("fast", "easy", "good" are banned)
[ ] Edge cases are covered (empty state, error state, limit state)
[ ] At least one criterion covers the unhappy path
```

### Step 3.3: Product Metadata

Fill the `product:` section of the YAML schema:

```yaml
product:
  feature_area: "[Product area, e.g., Checkout, Onboarding, Settings]"
  user_journey: "[High-level journey this belongs to]"
  success_metrics:
    - "[Metric name and target, e.g., 'Checkout completion rate > 85%']"
    - "[Metric name and target]"
  mockup_links:
    - "[Figma / Miro / Notion link]"
  analytics_events:
    - "[Event name fired when this feature is used]"
```

### Step 3.4: Technical & Business Context

Collaborate with engineering leads to estimate and flag risks before handoff.

```
TECHNICAL PRE-VIEW CHECKLIST

Complexity:     [low | medium | high | critical]
Effort Hours:   [Engineering estimate]
Impact:         [low | medium | high]
Risks:
  - id: risk-01
    description: "[What could go wrong]"
    mitigation: "[How to prevent it]"

Business:
  Priority:     [P0 | P1 | P2 | P3]
  KPIs Impacted: ["List of business metrics"]
  Revenue Impact: [Estimate or "N/A"]
  Cost Savings: [Estimate or "N/A"]
```

### Step 3.5: Story Map / Flow

For complex features, document the end-to-end flow.

```
USER FLOW

Step 1: [Entry point — where does the user start?]
Step 2: [Primary action — what does the user do?]
Step 3: [System response — what happens?]
Step 4: [Decision point — what branches exist?]
  ├── Branch A: [Happy path]
  └── Branch B: [Error / edge path]
Step 5: [Outcome — how does the user know it worked?]
```

---

## Expected Output

- Refined YAML files with complete `acceptance_criteria` (minimum 3 per story)
- `product:` metadata filled (feature_area, user_journey, success_metrics, mockup_links)
- `technical:` estimates and risks documented
- `business:` priorities and KPIs confirmed
- User flows for complex features
- Edge cases and unhappy paths documented
- All `spec-product/feat-*/` folders verified: naming convention intact, main file present

---

## Exit Criteria

- [ ] Every P0 and P1 story has 3+ acceptance criteria
- [ ] Acceptance criteria use Given/When/Then format
- [ ] At least one criterion covers an error or edge case
- [ ] `product.feature_area` and `product.user_journey` filled
- [ ] `product.success_metrics` defined with targets
- [ ] `technical.complexity` and `technical.effort_hours` estimated
- [ ] `business.priority` confirmed and aligned with roadmap
- [ ] Dependencies documented and verified
- [ ] Story status updated to `ready` or `in-review`
- [ ] `metadata.updated_at` timestamp updated on modified specs
- [ ] All spec folders follow naming convention: `feat-XXXX-dd-mm-yy-hh-mm/`
- [ ] Each folder contains at least the archivo principal: `feat-XXXX.yml`
- [ ] Archivos `.yml` adicionales relacionados viven dentro de la carpeta de la feature

---

## Rollback / Reprocess Rules

If an acceptance criterion is ambiguous:
1. Reject it. Rewrite it with concrete, measurable conditions.
2. Words like "fast", "easy", "user-friendly", "robust" are red flags.
3. Replace with numbers, states, or binary yes/no conditions.
4. Re-verify the Exit Criteria checklist.

If a spec folder naming convention is violated:
1. Rename the folder to `feat-XXXX-dd-mm-yy-hh-mm/` format.
2. Rename the file inside to `feat-XXXX.yml`.
3. Update any cross-references.
4. Re-verify before proceeding.
