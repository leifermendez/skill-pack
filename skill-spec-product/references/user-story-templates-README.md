# User Story YAML Templates

## Overview

These templates provide standardized YAML structures for documenting user stories in product specification projects.

Each user story YAML file captures:
- **Who** (role/persona)
- **What** (goal/action)
- **Why** (benefit/value)
- **Product context** (feature area, user journey, success metrics)
- **Acceptance criteria** (Given/When/Then)
- **Technical details** (complexity, effort, risks)
- **Business value** (priority, KPIs, revenue impact)

## Spec Folder & File Naming Convention

**Folder Format:** `spec-product/feat-XXXX-dd-mm-yy-hh-mm/`

- `XXXX`: Sequential 4-digit number (0001, 0002, ...). No gaps allowed.
- `dd-mm-yy-hh-mm`: Creation timestamp. 2-digit year.
- Example: `spec-product/feat-0001-15-05-26-14-30/`

**File Format (inside folder):** `feat-XXXX.yml`

- Only the ID. No timestamp, no descriptive slug.
- One file per folder. No additional files.
- Example: `spec-product/feat-0001-15-05-26-14-30/feat-0001.yml`

## Story Types

| Type | Description | Example Folder |
|------|-------------|----------------|
| `discovery` | Summary of discovery phase | `feat-0001-dd-mm-yy-hh-mm/` |
| `feature` | Functional feature | `feat-0002-dd-mm-yy-hh-mm/` |
| `technical` | Technical requirement/infrastructure | `feat-0005-dd-mm-yy-hh-mm/` |
| `pain` | Business pain point solution | `feat-0003-dd-mm-yy-hh-mm/` |
| `improvement` | Enhancement or optimization | `feat-0006-dd-mm-yy-hh-mm/` |
| `use-case` | Specific use case or scenario | `feat-0007-dd-mm-yy-hh-mm/` |

## Template Structure

```yaml
# spec-product/feat-XXXX-dd-mm-yy-hh-mm/feat-XXXX.yml
story:
  # Identification
  id: "feat-XXXX"
  type: "feature|technical|pain|improvement|use-case|discovery"
  status: "draft|refined|ready|in-review|approved|done"

  # User Story Statement (As a... I want... So that...)
  as_a: "[role]"
  i_want: "[goal/action]"
  so_that: "[benefit/value]"

  # Description
  description: "[Description in English]"

  # Product Context
  product:
    feature_area: "[AreaName]"
    user_journey: "[JourneyName]"
    success_metrics:
      - "[Metric name and target]"
    mockup_links:
      - "[Figma / Miro / Notion link]"
    analytics_events:
      - "[Event name fired when this feature is used]"

  # Acceptance Criteria (Given/When/Then)
  acceptance_criteria:
    - id: "ac-01"
      given: "[precondition]"
      when: "[action]"
      then: "[expected result]"

  # Technical Details
  technical:
    complexity: "low|medium|high|critical"
    effort_hours: "[estimated hours]"
    impact: "low|medium|high"
    risks:
      - id: "risk-01"
        description: "[Risk description]"
        mitigation: "[How to mitigate]"

  # Business Value
  business:
    priority: "P0|P1|P2|P3"
    kpis_impacted:
      - "[KPI name]"
    revenue_impact: "[estimate]"
    cost_savings: "[estimate]"

  # Dependencies
  dependencies:
    stories: ["feat-0001", "feat-0002"]
    systems: ["[External system]"]
    teams: ["[Team name]"]

  # Additional Notes
  notes:
    - "[Additional context]"

  # Metadata
  metadata:
    created_at: "dd-mm-yy-hh-mm"
    updated_at: "dd-mm-yy-hh-mm"
    author: "[name]"
    source: "discovery|stakeholder|analysis"
```

## Priority Levels

- **P0** (Blocking): Critical path, blocks other work, immediate attention
- **P1** (High): Major business value, important for quarter goals
- **P2** (Medium): Nice to have, can be deferred
- **P3** (Low): Future enhancement, minimal current impact

## Complexity Levels

- **Low**: Well-understood, straightforward implementation
- **Medium**: Some unknowns, requires research/spikes
- **High**: Significant unknowns, complex logic or integrations
- **Critical**: High risk, extensive unknowns, mission-critical

## Example Files

### 1. Discovery Summary
**Folder:** `spec-product/feat-0001-dd-mm-yy-hh-mm/`
**File:** `feat-0001.yml`

Use this as the first story to document discovery phase completion.

```yaml
story:
  id: "feat-0001"
  type: "discovery"
  status: "done"
  as_a: "Product Manager"
  i_want: "Document all discovery findings"
  so_that: "We have a clear baseline for design decisions"
```

### 2. Feature
**Folder:** `spec-product/feat-0002-dd-mm-yy-hh-mm/`
**File:** `feat-0002.yml`

Functional feature from the requirements collection.

```yaml
story:
  id: "feat-0002"
  type: "feature"
  status: "refined"
  as_a: "New Customer"
  i_want: "Register for an account with email verification"
  so_that: "I can securely access the platform features"
```

### 3. Pain Point
**Folder:** `spec-product/feat-0003-dd-mm-yy-hh-mm/`
**File:** `feat-0003.yml`

Solution to a documented business pain point.

```yaml
story:
  id: "feat-0003"
  type: "pain"
  status: "draft"
  as_a: "Finance Team Member"
  i_want: "Automated invoice generation from completed orders"
  so_that: "I can eliminate manual data entry errors and reduce processing time by 80%"
```

## Traceability

From user story to delivery:

```
spec-product/feat-0002-dd-mm-yy-hh-mm/feat-0002.yml
    ↓
Feature Area: Identity & Access
    ↓
User Journey: Onboarding
    ↓
Success Metrics: Registration completion rate > 85%
    ↓
Mockups: [Figma link]
    ↓
Engineering Ticket: [Linear/Jira link]
    ↓
Release: v2.3.0
```

## Workflow

1. **Discovery Phase**: Create `spec-product/feat-0001-dd-mm-yy-hh-mm/feat-0001.yml`
2. **Per Feature**: Create `spec-product/feat-0002-dd-mm-yy-hh-mm/feat-0002.yml` for each feature
3. **Per Pain Point**: Create `spec-product/feat-0003-dd-mm-yy-hh-mm/feat-0003.yml` for each pain point
4. **Per Improvement**: Create `spec-product/feat-0006-dd-mm-yy-hh-mm/feat-0006.yml` for optimizations
5. **Handoff**: Reference story ID in engineering tickets, commits, PRs

## Validation Checklist

Before marking a user story as "ready":

- [ ] ID follows convention (feat-XXXX)
- [ ] Type is valid (discovery/feature/technical/pain/improvement/use-case)
- [ ] As a / I want / So that complete
- [ ] Description provided
- [ ] Product context specified (feature_area, user_journey)
- [ ] At least one acceptance criterion
- [ ] Acceptance criteria use Given/When/Then format
- [ ] Technical complexity estimated
- [ ] Business priority assigned (P0-P3)
- [ ] Dependencies identified
- [ ] Metadata filled (created_at, updated_at, author, source)
- [ ] Folder name follows `feat-XXXX-dd-mm-yy-hh-mm/` format
- [ ] File inside folder is `feat-XXXX.yml`
- [ ] `metadata.created_at` matches folder timestamp

## Example Directory Structure

```
project/
├── spec-product/
│   ├── feat-0001-15-05-26-14-30/
│   │   └── feat-0001.yml
│   ├── feat-0002-15-05-26-16-45/
│   │   └── feat-0002.yml
│   ├── feat-0003-15-05-26-18-00/
│   │   └── feat-0003.yml
│   └── feat-0004-16-05-26-09-15/
│       └── feat-0004.yml
├── design/
│   └── [mockups, flows]
└── README.md
```

## Tools & Validation

### YAML Validation
Use any YAML validator to ensure syntax correctness:
- Online: yamllint.com
- CLI: `yamllint spec-product/*/*.yml`
- VSCode: YAML extension with schema validation

### Schema Validation
Recommended schema (JSON Schema format):

```json
{
  "type": "object",
  "properties": {
    "story": {
      "type": "object",
      "required": ["id", "type", "as_a", "i_want", "so_that", "product"]
    }
  }
}
```

## References

- BDD (Behavior-Driven Development): Given/When/Then format
- User Story Mapping: Jeff Patton's approach
- Story points and estimation: Scrum/Agile practices

---

**Remember:** User stories in YAML are living documents. Update them as the product understanding evolves!
