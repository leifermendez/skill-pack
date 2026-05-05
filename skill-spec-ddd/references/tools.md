# Tools & Software

> **Recommended tools for each phase of Spec-Driven Development.**

---

## Discovery & Modeling

### Event Storming

| Tool | Type | Best For | Cost |
|------|------|----------|------|
| **Miro** | Online Whiteboard | Remote teams, collaboration | Freemium |
| **Mural** | Online Whiteboard | Enterprise, facilitators | Paid |
| **Physical Stickies** | In-person | Co-located teams, energy | $ |
| **Lucidchart** | Diagramming | Documentation, formal diagrams | Freemium |

**Recommended:** Miro for remote, physical for in-person

**Setup:**
- Create infinite canvas
- Prepare color legend:
  - 🟠 Orange: Domain Events
  - 🔵 Blue: Commands  
  - 🟡 Yellow: Aggregates
  - 🟢 Green: Actors
  - 🟣 Purple: Policies
  - 🔴 Red: Hot spots

---

### Context Mapping

| Tool | Type | Best For |
|------|------|----------|
| **diagrams.net** (draw.io) | Diagramming | Free, offline capable |
| **Visual Paradigm** | UML/Modeling | Enterprise, formal modeling |
| **Miro** | Whiteboard | Quick sketches, collaboration |
| **Structurizr** | C4 Model | Architecture documentation |

**Recommended:** diagrams.net for most cases, Structurizr for formal C4

---

## Code & Implementation

### DDD Code Modeling

| Tool | Language | Purpose |
|------|----------|---------|
| **ArchUnit** | Java | Architecture testing, dependency rules |
| **ArchUnitNET** | .NET | Architecture testing for .NET |
| **PyDantic** | Python | Domain modeling, validation |
| **Zod** | TypeScript | Schema validation, type safety |
| **io-ts** | TypeScript | Runtime type validation |
| **JetBrains DDD Plugin** | JVM | IDE support for DDD patterns |

**ArchUnit Example:**
```java
// Ensure aggregates don't reference other aggregates directly
@ArchTest
static final ArchRule aggregateRule = classes()
    .that().resideInAPackage("..domain..")
    .and().areAnnotatedWith(AggregateRoot.class)
    .should().onlyAccessClassesThat()
    .resideOutsideOfPackages("..otheraggregates..");
```

---

## CI/CD {#cicd}

### Pipeline Tools

| Tool | Type | Best For |
|------|------|----------|
| **GitHub Actions** | CI/CD | GitHub repos, easy setup |
| **GitLab CI** | CI/CD | GitLab repos, integrated |
| **Jenkins** | CI/CD | Self-hosted, complex pipelines |
| **CircleCI** | CI/CD | Fast, cloud-native |
| **ArgoCD** | GitOps | Kubernetes deployments |

**SDD-Specific CI Checks:**
```yaml
# Example GitHub Actions workflow
name: SDD Validation

on: [push, pull_request]

jobs:
  validate-specs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      # 1. Validate YAML schema
      - name: Validate User Story YAML
        run: |
          yamllint spec-ddd/
          jsonschema -i spec-ddd/*.yml schema/user-story-schema.json
      
      # 2. Check commit message format
      - name: Validate Commit Messages
        uses: gsactions/commit-message-checker@v1
        with:
          pattern: '^(feat|fix|refactor|test|docs|chore)\(feat-\d{3}\): .*$'
          error: 'Commit messages must follow SDD convention'
      
      # 3. Architecture tests
      - name: Run ArchUnit
        run: ./gradlew test --tests "*ArchitectureTest*"
```

---

## Observability & Monitoring {#observability}

### Metrics

| Tool | Type | Best For |
|------|------|----------|
| **Prometheus** | Metrics | Kubernetes, time-series |
| **Datadog** | APM | Enterprise, full stack |
| **New Relic** | APM | Application performance |
| **Grafana** | Visualization | Dashboards, metrics display |

### Logging

| Tool | Type | Best For |
|------|------|----------|
| **ELK Stack** | Logs | Search, analysis |
| **Splunk** | Logs | Enterprise, heavy volume |
| **Loki** | Logs | Grafana integration |
| **Seq** | Logs | .NET, structured logging |

### Tracing

| Tool | Type | Best For |
|------|------|----------|
| **Jaeger** | Tracing | Distributed tracing |
| **Zipkin** | Tracing | Open source, simple |
| **AWS X-Ray** | Tracing | AWS ecosystem |

### SDD-Specific Observability

**Domain Metrics to Track:**
- Aggregate creation rate
- Domain event frequency by type
- Command handling time
- Invariant violation count

**Log Correlation IDs:**
```json
{
  "trace_id": "abc-123",
  "span_id": "def-456",
  "aggregate_id": "order-789",
  "correlation_id": "payment-flow-xyz",
  "story_id": "feat-002",
  "event_type": "OrderShipped"
}
```

---

## Documentation

### Architecture Documentation

| Tool | Format | Best For |
|------|--------|----------|
| **Arc42** | Template | German standard, comprehensive |
| **C4 Model** | Diagrams | Layered architecture views |
| **MADR** | Markdown | Architecture Decision Records |
| **adr-tools** | CLI | Managing ADR files |

**MADR Template:**
```markdown
# ADR-001: Use PostgreSQL for persistence

## Status
Accepted

## Context
Need to choose database for Order aggregate

## Decision
Use PostgreSQL with JSONB for flexible schema

## Consequences
- ✅ ACID transactions for aggregates
- ✅ JSONB for event store
- ❌ Operational complexity
```

---

## User Stories & Specs

### YAML Tools

| Tool | Purpose |
|------|---------|
| **VS Code YAML Extension** | Validation, autocomplete |
| **yamllint** | CI validation |
| **JSON Schema** | Schema validation |
| **Spectral** | OpenAPI/YAML linting |

**VS Code Setup:**
```json
// .vscode/settings.json
{
  "yaml.schemas": {
    "schema/user-story.schema.json": "spec-ddd/*.yml"
  },
  "yaml.customTags": [
    "!story",
    "!domain"
  ]
}
```

---

## Testing

### Testing Tools by Type

| Type | Tool | Purpose |
|------|------|---------|
| **Unit** | Jest, xUnit, pytest | Domain logic testing |
| **Integration** | TestContainers, Docker | Repository testing |
| **Contract** | Pact, Spring Cloud Contract | API contracts |
| **E2E** | Cypress, Playwright | User journey testing |
| **Property** | fast-check, Hypothesis | Generative testing |
| **Mutation** | Stryker, Infection | Test quality |

**Contract Testing Example (Pact):**
```typescript
// Consumer (Order Service)
const pact = new Pact({
  consumer: 'Order Service',
  provider: 'Payment Service'
});

await pact
  .given('payment exists')
  .uponReceiving('request to process payment')
  .withRequest({
    method: 'POST',
    path: '/payments',
    body: { orderId: '123', amount: 100.00 }
  })
  .willRespondWith({
    status: 200,
    body: Matchers.like({ paymentId: 'uuid' })
  });
```

---

## Communication & Collaboration

### Team Tools

| Tool | Purpose | SDD Integration |
|------|---------|---------------|
| **Slack** | Messaging | PR notifications, CI alerts |
| **Notion** | Wiki | Domain documentation |
| **Confluence** | Wiki | ADR storage |
| **Linear** | Issue Tracking | Story tracking |
| **Jira** | Project Management | Sprint planning |

---

## Recommended Tool Stack

### Minimal Setup (Start Here)
```
Discovery:    Miro (free tier)
Modeling:     diagrams.net
Code:         Your IDE + DDD plugin
CI/CD:        GitHub Actions
Docs:         MADR + Markdown
Observability: Console + Basic metrics
```

### Professional Setup
```
Discovery:    Miro + Physical sessions
Modeling:     Structurizr (C4)
Code:         ArchUnit + IDE plugins
CI/CD:        GitHub Actions + ArgoCD
Docs:         Arc42 + ADR-tools
Observability: Prometheus + Grafana + Jaeger
Testing:      Pact (contracts) + TestContainers
```

### Enterprise Setup
```
Discovery:    Mural + Facilitation training
Modeling:     Visual Paradigm + C4
Code:         Full ArchUnit suite + Custom rules
CI/CD:        Jenkins + GitOps
Docs:         Confluence + Structurizr
Observability: Datadog/New Relic full stack
Testing:      Full pyramid + Mutation testing
```

---

## Tool Integration Checklist

```
□ YAML validation in IDE (VS Code extension)
□ Pre-commit hooks for commit message format
□ CI pipeline rejects non-compliant commits
□ Architecture tests in build pipeline
□ Contract tests between services
□ Automated ADR generation (adr-tools)
□ Observability dashboard (Grafana/Datadog)
□ Story traceability from commit to deploy
```

---

## Related Resources

- [Event Storming Guide](event-storming.md)
- [DDD Pattern Library](ddd-pattern-library.md)
- [Books](books.md) - For tool selection theory
- [Back to SKILL.md](../SKILL.md)
