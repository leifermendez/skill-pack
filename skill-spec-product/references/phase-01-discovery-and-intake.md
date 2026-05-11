# Phase 01: Discovery & Intake

## Objective

Transform vague requests, complaints, and ideas into a structured, traceable requirements package. Collect enough context for product to make informed prioritization and specification decisions later.

## Input Required

None. This is the starting phase.

---

## Steps

### Step 1.1: Mandatory Discovery

Before any analysis, collect at least **3 items** in each category below. Ask clarifying questions until the minimum is reached.

#### A. Problem Statements

Define the PROBLEMS we are solving. Not features — problems.

| # | Question | Input |
|---|----------|-------|
| 1 | What is the primary user pain point or business opportunity? | |
| 2 | Who is affected and how often does this occur? | |
| 3 | What is the current workaround, if any? | |
| 4 | What happens if this problem is not solved? | |
| 5 | What is the desired user outcome? | |

**Minimum 3 problem statements documented before proceeding.**

#### B. Context & Constraints

Define the boundaries of the request.

| # | Question | Input |
|---|----------|-------|
| 1 | What is the expected user/transaction volume? | |
| 2 | Are there regulatory, legal, or compliance constraints? | |
| 3 | Are there hard deadlines (events, contracts, launches)? | |
| 4 | What systems or teams will this touch? | |
| 5 | What is the approximate budget or resource envelope? | |

**Minimum 3 context items documented before proceeding.**

#### C. Known Requests & Ideas

Capture what has already been asked for.

| # | Question | Input |
|---|----------|-------|
| 1 | What features have users or stakeholders explicitly requested? | |
| 2 | What has the support team flagged as a recurring issue? | |
| 3 | What have competitors shipped that we lack? | |
| 4 | What internal teams have flagged as a blocker? | |
| 5 | What quick wins have been identified? | |

**Minimum 3 requests/ideas documented before proceeding.**

---

### Step 1.2: Stakeholder Mapping

Map who cares about this initiative:

```
STAKEHOLDER MAP

Primary Users:     [End users who experience the problem]
Secondary Users:   [Admins, ops, CS agents who are affected]
Decision Makers:   [Execs, product leadership, budget owners]
Blockers/Risks:    [Legal, compliance, security review]
Delivery Partners: [Design, engineering, data, marketing]
```

---

### Step 1.3: Spec Folder Generation

After collecting requirements, immediately create spec folders.

#### Folder Naming Convention

```
spec-product/
└── feat-0001-dd-mm-yy-hh-mm/
    └── feat-0001.yml          # Discovery summary
└── feat-0002-dd-mm-yy-hh-mm/
    └── feat-0002.yml          # Per problem statement (min 3)
└── feat-0003-dd-mm-yy-hh-mm/
    └── feat-0003.yml          # Per explicit request (min 3)
└── feat-0004-dd-mm-yy-hh-mm/
    └── feat-0004.yml          # Per identified improvement
```

**Rules:**
- Use sequential 4-digit numbering: `feat-0001`, `feat-0002`, etc. No gaps.
- Folder name includes timestamp: `feat-XXXX-dd-mm-yy-hh-mm/`
- File inside folder: `feat-XXXX.yml` (no timestamp, no slug)
- Archivo principal: `feat-XXXX.yml`. Se permiten archivos YAML adicionales relacionados con la misma feature dentro de la carpeta.

#### Git Naming Conventions

All user stories MUST include Git branch, commit, and PR naming conventions for traceability.

NOTA: Estas convenciones se documentan exclusivamente como metadata dentro del bloque `git:` del YAML.
Este skill NO crea branches, NO genera commits y NO abre PRs.

**Branch Naming**

```
Format:    <type>/feat-<XXXX>-<short-description>

Examples:
  feat/feat-0002-user-reg
  fix/feat-0002-email-verify-bug
  refactor/feat-0006-order-flow

Types:
  feat/     - New feature implementation
  fix/      - Bug fix related to a user story
  refactor/ - Code refactoring without behavior change
  test/     - Adding/updating tests for a user story
  docs/     - Documentation updates for a feature
```

**Commit Message Convention**

```
Format:    <type>(feat-XXXX): <description>

Examples:
  feat(feat-0002): implement user registration flow
  fix(feat-0003): correct tax calculation for EU customers
  test(feat-0002): add unit tests for checkout flow

Rules:
- ALWAYS include feature ID in parentheses: (feat-XXXX)
- Use imperative mood: "add" not "added", "fix" not "fixed"
- First letter lowercase
- No period at the end
- Maximum 72 characters in subject line
```

**PR Naming**

```
Format:    <type>(feat-XXXX): <Short Description>

Template for PR Description:
  ## Related User Story
  Closes spec-product/feat-XXXX-dd-mm-yy-hh-mm/feat-XXXX.yml

  ## Changes
  - [List of changes]

  ## Acceptance Criteria Verified
  - [x] AC-01: [description]
  - [x] AC-02: [description]

  ## Testing
  - [How this was tested]
```

#### User Story YAML Schema

Each `.yml` file MUST follow this structure:

```yaml
# spec-product/feat-XXXX-dd-mm-yy-hh-mm/feat-XXXX.yml
story:
  id: "feat-XXXX"
  type: "discovery|feature|technical|pain|improvement|use-case"
  status: "draft|refined|ready|in-review|approved|done"

  as_a: "[role]"
  i_want: "[goal/action]"
  so_that: "[benefit/value]"

  description: "[Description in English]"

  product:
    feature_area: "[AreaName]"
    user_journey: "[JourneyName]"
    success_metrics: ["Metric1", "Metric2"]
    mockup_links: ["https://..."]
    analytics_events: ["Event1", "Event2"]

  acceptance_criteria:
    - id: "ac-01"
      given: "[precondition]"
      when: "[action]"
      then: "[expected result]"

  technical:
    complexity: "low|medium|high|critical"
    effort_hours: "[estimated hours]"
    impact: "low|medium|high"
    risks:
      - id: "risk-01"
        description: "Risk description"
        mitigation: "How to mitigate"

  business:
    priority: "P0|P1|P2|P3"
    kpis_impacted:
      - "[KPI name]"
    revenue_impact: "[estimate]"
    cost_savings: "[estimate]"

  dependencies:
    stories: ["feat-0001", "feat-0002"]
    systems: ["External API", "Database"]
    teams: ["Team A", "Team B"]

  notes:
    - "[Additional context]"

  git:
    branch_name: "feat/feat-XXXX-short-description"
    commit_prefix: "feat(feat-XXXX):"
    pr_title: "feat(feat-XXXX): Short description"
    related_commits: []

  metadata:
    created_at: "dd-mm-yy-hh-mm"
    updated_at: "dd-mm-yy-hh-mm"
    author: "[name]"
    source: "discovery|stakeholder|analysis"
```

---

## Expected Output

- `spec-product/feat-0001-dd-mm-yy-hh-mm/feat-0001.yml` - Discovery summary
- `spec-product/feat-0002-*` through `feat-0004-*` - Per problem, request, and improvement
- Stakeholder map documented

Toda la salida de esta fase son archivos YAML creados dentro de `spec-product/`. Este skill no realiza acciones de Git.

---

## Exit Criteria

- [ ] Minimum 3 problem statements documented
- [ ] Minimum 3 context/constraints documented
- [ ] Minimum 3 requests/ideas documented
- [ ] Stakeholder map created
- [ ] Spec folders created in `spec-product/` following naming convention
- [ ] Each folder contains at least the archivo principal: `feat-XXXX.yml`
- [ ] Todos los archivos `.yml` adicionales relacionados con la feature viven dentro de la misma carpeta
- [ ] All YAML files follow the schema (id, type, as_a, i_want, so_that, product)
- [ ] `metadata.created_at` matches folder timestamp
- [ ] Git naming conventions documented for the team

---

## Rollback / Reprocess Rules

If any Exit Criteria item is missing:
1. Halt. Do not proceed to Phase 02.
2. Identify the missing item.
3. Ask the user clarifying questions to fill the gap.
4. Update the relevant YAML file or rename the folder if needed.
5. Re-verify the Exit Criteria checklist.

If a folder name violates the convention:
1. Rename it to `feat-XXXX-dd-mm-yy-hh-mm/` format.
2. Ensure the file inside is `feat-XXXX.yml`.
3. Re-verify before proceeding.
