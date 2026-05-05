# User Story YAML Templates

## 📋 Overview

These templates provide standardized YAML structures for documenting user stories in DDD (Domain-Driven Design) projects.

Each user story YAML file captures:
- **Who** (role/persona)
- **What** (goal/action)
- **Why** (benefit/value)
- **Domain context** (bounded context, aggregates, events)
- **Acceptance criteria** (Given/When/Then in ES/EN)
- **Technical details** (complexity, effort, risks)
- **Business value** (priority, KPIs, revenue impact)

## 📁 File Naming Convention

```
spec-ddd/feat-XXX-descriptive-name.yml

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

## 🏗️ Story Types

| Type | Description | Example |
|------|-------------|---------|
| `discovery` | Summary of discovery phase | feat-001-discovery.yml |
| `scope` | Functional scope item | feat-002-user-registration.yml |
| `technical` | Technical requirement/infrastructure | feat-005-database-sharding.yml |
| `pain` | Business pain point solution | feat-003-manual-invoicing.yml |
| `aggregate` | Aggregate design/implementation | feat-006-order-aggregate.yml |
| `use-case` | Specific use case/command/query | feat-007-cancel-order.yml |

## 📝 Template Structure

```yaml
story:
  # Identification
  id: "feat-XXX"
  type: "scope|technical|pain|aggregate|use-case|discovery"
  status: "draft|refined|ready|done"
  
  # User Story Statement (As a... I want... So that...)
  as_a: "[role]"
  i_want: "[goal/action]"
  so_that: "[benefit/value]"
  
  # Bilingual Description
  description:
    es: "[Descripción en español]"
    en: "[Description in English]"
  
  # DDD Domain Context
  domain:
    bounded_context: "[ContextName]"
    aggregate: "[AggregateName]"
    entities: ["Entity1", "Entity2"]
    value_objects: ["ValueObject1", "ValueObject2"]
    domain_events: ["Event1", "Event2"]
  
  # Acceptance Criteria (Given/When/Then)
  acceptance_criteria:
    - id: "ac-01"
      given: "[precondition]"
      when: "[action]"
      then: "[expected result]"
      es:
        dado: "[precondición]"
        cuando: "[acción]"
        entonces: "[resultado esperado]"
  
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
    kpis_impacted: ["[KPI name]"]
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

## 🎯 Priority Levels

- **P0** (Blocking): Critical path, blocks other work, immediate attention
- **P1** (High): Major business value, important for MVP
- **P2** (Medium): Nice to have, can be deferred
- **P3** (Low): Future enhancement, minimal current impact

## 📊 Complexity Levels

- **Low**: Well-understood, straightforward implementation
- **Medium**: Some unknowns, requires research/spikes
- **High**: Significant unknowns, complex domain logic
- **Critical**: High risk, extensive unknowns, mission-critical

## 🌍 Bilingual Support

All user stories MUST include both Spanish (es) and English (en) for:
- Description
- Acceptance criteria (given/when/then)

This ensures international team collaboration and documentation clarity.

## 📁 Example Files

### 1. Discovery Summary
**File:** `feat-001-discovery.yml`

Use this as the first story to document discovery phase completion.

```yaml
story:
  id: "feat-001"
  type: "discovery"
  status: "done"
  as_a: "System Architect"
  i_want: "Document all discovery findings"
  so_that: "We have a clear baseline for design decisions"
```

### 2. Scope Item
**File:** `feat-002-user-registration.yml`

Functional feature from the scope collection.

```yaml
story:
  id: "feat-002"
  type: "scope"
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

## 🔗 Integration with DDD

Each user story maps to DDD concepts:

```
User Story → Bounded Context → Aggregate → Entities/Value Objects
                                                    ↓
                                            Domain Events
                                                    ↓
                                           Event Storming
```

### Traceability

From user story to code:

```
spec-ddd/feat-002-user-registration.yml
    ↓
Bounded Context: IdentityManagement
    ↓
Aggregate: User
    ↓
Domain Events: UserRegistered, EmailVerificationSent, EmailVerified
    ↓
Code:
  src/
    identity-management/
      domain/
        aggregate/
          User.ts
        events/
          UserRegistered.ts
          EmailVerificationSent.ts
```

## 🚀 Workflow

1. **Discovery Phase**: Create `feat-001-discovery.yml` with summary
2. **Per Scope Item**: Create `feat-002-[scope-name].yml` for each scope
3. **Per Pain Point**: Create `feat-00X-[pain-name].yml` for each pain point
4. **Per Aggregate**: Create `feat-0XX-[aggregate-name].yml` for identified aggregates
5. **Implementation**: Reference story ID in code comments, commits, PRs

## ✅ Validation Checklist

Before marking a user story as "ready":

- [ ] ID follows convention (feat-XXX)
- [ ] Type is valid (discovery/scope/technical/pain/aggregate/use-case)
- [ ] As a / I want / So that complete
- [ ] Description in both ES and EN
- [ ] Domain context specified (bounded context, aggregate)
- [ ] At least one acceptance criterion
- [ ] Acceptance criteria have ES translations
- [ ] Technical complexity estimated
- [ ] Business priority assigned (P0-P3)
- [ ] Dependencies identified
- [ ] Metadata filled (created_at, author, source)

## 📝 Example Directory Structure

```
project/
├── spec-ddd/
│   ├── feat-001-discovery.yml
│   ├── feat-002-user-registration.yml
│   ├── feat-003-user-authentication.yml
│   ├── feat-004-password-reset.yml
│   ├── feat-005-manual-invoicing.yml
│   ├── feat-006-order-management.yml
│   ├── feat-007-inventory-tracking.yml
│   └── feat-008-payment-processing.yml
├── src/
│   └── [implementation]
└── README.md
```

## 🔧 Tools & Validation

### YAML Validation
Use any YAML validator to ensure syntax correctness:
- Online: yamllint.com
- CLI: `yamllint spec-ddd/*.yml`
- VSCode: YAML extension with schema validation

### Schema Validation
Recommended schema (JSON Schema format):

```json
{
  "type": "object",
  "properties": {
    "story": {
      "type": "object",
      "required": ["id", "type", "as_a", "i_want", "so_that", "domain"]
    }
  }
}
```

## 📚 References

- BDD (Behavior-Driven Development): Given/When/Then format
- DDD (Domain-Driven Design): Aggregates, Bounded Contexts
- User Story Mapping: Jeff Patton's approach
- Event Storming: Alberto Brandolini's method

---

**Remember:** User stories in YAML are living documents. Update them as the domain understanding evolves!
