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

## File Naming Convention

```
spec-product/feat-XXX-descriptive-name.yml

Examples:
- feat-001-discovery.yml
- feat-002-user-registration.yml
- feat-003-manual-invoicing.yml
- feat-004-payment-gateway.yml
```

**Rules:**
- Sequential numbering: `feat-001`, `feat-002`, etc.
- Kebab-case for descriptive part
- Maximum 50 characters total
- Must be unique within project

## Story Types

| Type | Description | Example |
|------|-------------|---------|
| `discovery` | Summary of discovery phase | feat-001-discovery.yml |
| `feature` | Functional feature | feat-002-user-registration.yml |
| `technical` | Technical requirement/infrastructure | feat-005-database-sharding.yml |
| `pain` | Business pain point solution | feat-003-manual-invoicing.yml |
| `improvement` | Enhancement or optimization | feat-006-checkout-speed.yml |
| `use-case` | Specific use case or scenario | feat-007-cancel-order.yml |

## Template Structure

```yaml
story:
  # Identification
  id: "feat-XXX"
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
    stories: ["feat-001", "feat-002"]
    systems: ["[External system]"]
    teams: ["[Team name]"]

  # Additional Notes
  notes:
    - "[Additional context]"

  # Metadata
  metadata:
    created_at: "YYYY-MM-DD"
    updated_at: "YYYY-MM-DD"
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
**File:** `feat-001-discovery.yml`

Use this as the first story to document discovery phase completion.

```yaml
story:
  id: "feat-001"
  type: "discovery"
  status: "done"
  as_a: "Product Manager"
  i_want: "Document all discovery findings"
  so_that: "We have a clear baseline for design decisions"
```

### 2. Feature
**File:** `feat-002-user-registration.yml`

Functional feature from the requirements collection.

```yaml
story:
  id: "feat-002"
  type: "feature"
  status: "refined"
  as_a: "New Customer"
  i_want: "Register for an account with email verification"
  so_that: "I can securely access the platform features"
```

### 3. Pain Point
**File:** `feat-003-manual-invoicing.yml`

Solution to a documented business pain point.

```yaml
story:
  id: "feat-003"
  type: "pain"
  status: "draft"
  as_a: "Finance Team Member"
  i_want: "Automated invoice generation from completed orders"
  so_that: "I can eliminate manual data entry errors and reduce processing time by 80%"
```

## Traceability

From user story to delivery:

```
spec-product/feat-002-user-registration.yml
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

1. **Discovery Phase**: Create `feat-001-discovery.yml` with summary
2. **Per Feature**: Create `feat-002-[feature-name].yml` for each feature
3. **Per Pain Point**: Create `feat-00X-[pain-name].yml` for each pain point
4. **Per Improvement**: Create `feat-0XX-[improvement-name].yml` for optimizations
5. **Handoff**: Reference story ID in engineering tickets, commits, PRs

## Validation Checklist

Before marking a user story as "ready":

- [ ] ID follows convention (feat-XXX)
- [ ] Type is valid (discovery/feature/technical/pain/improvement/use-case)
- [ ] As a / I want / So that complete
- [ ] Description provided
- [ ] Product context specified (feature_area, user_journey)
- [ ] At least one acceptance criterion
- [ ] Acceptance criteria use Given/When/Then format
- [ ] Technical complexity estimated
- [ ] Business priority assigned (P0-P3)
- [ ] Dependencies identified
- [ ] Metadata filled (created_at, author, source)

## Example Directory Structure

```
project/
├── spec-product/
│   ├── feat-001-discovery.yml
│   ├── feat-002-user-registration.yml
│   ├── feat-003-user-authentication.yml
│   ├── feat-004-password-reset.yml
│   ├── feat-005-manual-invoicing.yml
│   ├── feat-006-order-management.yml
│   ├── feat-007-inventory-tracking.yml
│   └── feat-008-payment-processing.yml
├── design/
│   └── [mockups, flows]
└── README.md
```

## Tools & Validation

### YAML Validation
Use any YAML validator to ensure syntax correctness:
- Online: yamllint.com
- CLI: `yamllint spec-product/*.yml`
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
