# Phase 02: Prioritization

## Objective

Transform the raw requirements package into a ranked, time-bound roadmap. Decide what gets built now, next, or never.

## Input Required

- All spec folders from `spec-product/` created in Phase 01
- Stakeholder map
- Business KPIs and strategic goals

---

## Steps

### Step 2.1: Scoring Model

Apply a consistent scoring framework to every candidate story. Recommended: **RICE**.

```
RICE SCORING

Reach:     [How many users will this affect per quarter?]
Impact:    [3 = Massive, 2 = High, 1 = Medium, 0.5 = Low]
Confidence:[100% = High evidence, 80% = Medium, 50% = Low]
Effort:    [Person-months or story points]

Score = (Reach × Impact × Confidence) / Effort
```

Alternative: **WSJF** (Weighted Shortest Job First) for capacity-constrained teams.

```
WSJF SCORING

Cost of Delay = User/Business Value + Time Criticality + Risk Reduction
Job Size      = Estimated effort

WSJF = Cost of Delay / Job Size
```

### Step 2.2: Categorization

Group stories by strategic theme and urgency.

```
PRIORITIZATION MATRIX

            High Impact
                 │
     Strategic   │   Quick Wins
     Initiatives │   (Do First)
                  │
     ────────────┼─────────────
                  │
     Fill-ins     │   Thankless
     (Do Later)   │   Tasks (Avoid)
                  │
            Low Impact
                  Low Effort    High Effort
```

### Step 2.3: Quarter Roadmap

Map prioritized stories into time-bound quarters.

```
QUARTER ROADMAP

Q1 (Now)
├── Theme: [Quarterly goal]
├── P0 Stories: [feat-0002, feat-0003, ...]
├── P1 Stories: [feat-0005, feat-0006, ...]
└── Milestone: [Specific deliverable by end of quarter]

Q2 (Next)
├── Theme: [Quarterly goal]
├── P0 Stories: [...]
└── Milestone: [...]

Q3+ (Later)
├── Backlog: [Unscheduled stories with RICE scores]
└── Review cadence: Monthly re-prioritization
```

**Rules:**
- A quarter should contain no more than 3 P0 themes.
- P0 stories must have stakeholder sign-off before engineering starts.
- Every story in the quarter roadmap must have a success metric.

### Step 2.4: Dependency Check

Before locking the roadmap, verify that no story depends on something scheduled later.

```
DEPENDENCY CHECKLIST

Story ID    │ Dependencies │ Scheduled Quarter │ Conflict?
────────────┼──────────────┼───────────────────┼──────────
feat-0002   │ feat-0001    │ Q1                │ OK
feat-0003   │ feat-0007    │ Q2                │ BLOCKED
```

If a dependency is scheduled later, either:
- Move the dependency earlier, or
- Move the dependent story later, or
- Split the dependent story to remove the dependency.

---

## Expected Output

- RICE or WSJF scores for every candidate story
- Prioritization matrix
- Quarter roadmap (Q1, Q2, Q3+)
- Dependency conflict resolution
- Updated YAML files with `business.priority` and `dependencies` filled
- Spec folders verified: naming convention, timestamps match, main file present

---

## Exit Criteria

- [ ] Every story in the package has a priority score (RICE/WSJF)
- [ ] Quarter roadmap defined with themes and milestones
- [ ] No dependency conflicts (all upstreams scheduled before downstreams)
- [ ] P0 stories identified and approved by decision makers
- [ ] P1 and P2 stories slotted into quarters or backlog
- [ ] YAML files updated with priority and dependency information
- [ ] All `spec-product/feat-*/` folders still follow naming convention
- [ ] `metadata.updated_at` timestamp updated on modified specs

---

## Rollback / Reprocess Rules

If a dependency conflict cannot be resolved:
1. Flag the conflict in the risk register.
2. Schedule a stakeholder review to decide: move, split, or descope.
3. Do not proceed to Phase 03 until the conflict is resolved.

If a folder or file naming convention is violated during updates:
1. Rename the folder or file to match the convention.
2. Update any internal references (dependencies, PR templates).
3. Re-verify before proceeding.
