# Risk Matrix Reference (Matriz de Riesgos)

> **PRINCIPLE**: "What can go wrong, will go wrong. Document it before it documents you."

Quick reference for identifying and mitigating risks in Spec-Driven Development (SDD) projects.

---

## Risk Assessment Framework

### Severity Levels

| Level | Description | Examples |
|-------|-------------|----------|
| **P0 (Critical)** | Blocks release, legal/compliance issue, catastrophic data loss | Security breach, data corruption, regulatory violation |
| **P1 (High)** | Significant business impact, major feature failure | Core feature broken, 3rd party API failure, performance degradation |
| **P2 (Medium)** | Workarounds exist, partial feature failure | Minor bugs, UI issues, non-critical features down |
| **P3 (Low)** | Minor inconvenience, cosmetic issues | Typos, layout issues, nice-to-have missing |

### Probability Levels

- **Probable (>70%)**: Likely to occur without intervention
- **Possible (30-70%)**: May occur, monitor closely  
- **Unlikely (<30%)**: Low chance, but high impact if it does

---

## Risk Register Template

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  RISK REGISTER - Project: [Name] - Date: [YYYY-MM-DD]                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ID    │ RISK DESCRIPTION          │ PROBABILITY │ IMPACT │ LEVEL │ STATUS  │
│  ──────┼───────────────────────────┼─────────────┼────────┼───────┼─────────│
│  R-001 │ [Technical/Business/Process] │ [P/U]       │ [P0-3] │ [C/W/A]│ [O/C]  │
│  R-002 │                           │             │        │       │         │
│  R-003 │                           │             │        │       │         │
│                                                                              │
│  Legend:                                                                     │
│  • Probability: Pr=Probable, Po=Possible, U=Unlikely                        │
│  • Level: C=Critical, W=Warning, A=Accepted                               │
│  • Status: O=Open, C=Closed, M=Mitigated                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Risk Categories for SDD Projects

### 🔴 Technical Risks (Riesgos Técnicos)

| ID | Risk Area | Risk Description | Mitigation Strategy |
|----|-----------|------------------|---------------------|
| T-001 | **Spec Drift** | YAML specs become outdated vs. actual code | • CI validation: specs must be updated before PR merge<br>• Automated spec-code diff checker |
| T-002 | **Complexity Underestimation** | User story effort hours significantly off | • Always use 3-point estimation (optimistic/pessimistic/realistic)<br>• Add 30% buffer for SDD overhead |
| T-003 | **Integration Failures** | External systems don't match spec contracts | • Contract testing (Pact/OpenAPI)<br>• ACL (Anti-Corruption Layer) mandatory |
| T-004 | **Performance at Scale** | System doesn't handle projected 10x load | • Load testing in Sprint 0<br>• Performance budgets defined in YAML |
| T-005 | **Event Storming Gaps** | Domain events missed during discovery | • Mandatory Event Storming session<br>• Quarterly event review |
| T-006 | **Aggregate Boundary Leakage** | Transactions span multiple aggregates | • Architecture tests (ArchUnit)<br>• Code review checklist for aggregate rules |

### 🟠 Business Risks (Riesgos de Negocio)

| ID | Risk Area | Risk Description | Mitigation Strategy |
|----|-----------|------------------|---------------------|
| B-001 | **Stakeholder Misalignment** | Business language in specs ≠ actual business needs | • Dual-language validation with stakeholders<br>• Sign-off on ubiquitous language |
| B-002 | **Priority Conflicts** | P0 stories compete for same resources | • WSJF (Weighted Shortest Job First) scoring in YAML<br>• Capacity planning per sprint |
| B-003 | **Regulatory Changes** | Compliance requirements shift mid-project | • ADR for compliance strategy<br>• Quarterly legal review checkpoint |
| B-004 | **Vendor Lock-in** | External system dependencies become blockers | • Anti-Corruption Layer mandatory<br>• Abstraction interfaces for external services |
| B-005 | **ROI Unclear** | Cost savings/revenue impact estimates wrong | • Real metrics tracking vs. YAML predictions<br>• Monthly business review of delivered stories |

### 🟡 Process Risks (Riesgos de Proceso SDD)

| ID | Risk Area | Risk Description | Mitigation Strategy |
|----|-----------|------------------|---------------------|
| P-001 | **Git Convention Fatigue** | Team stops following branch/commit conventions | • Pre-commit hooks validation<br>• CI pipeline rejects non-compliant PRs |
| P-002 | **YAML Schema Errors** | Invalid YAML structure breaks traceability | • JSON Schema validation in CI<br>• Editor plugins with autocomplete |
| P-003 | **Analysis Paralysis** | Stuck in discovery/analysis phases | • Time-boxed phases (2 weeks max per phase)<br>• "Good enough" criteria defined upfront |
| P-004 | **Knowledge Silos** | Only one person understands the domain model | • Mandatory pair programming for aggregate design<br>• Domain model documentation in repo |
| P-005 | **Traceability Breakdown** | Commits lose connection to user stories | • Git hooks enforcing commit message format<br>• Automated linking via story_id in commit metadata |
| P-006 | **Sprint 0 Never Ends** | Foundation phase extends indefinitely | • Fixed 2-week Sprint 0 with clear DoD<br>• Escalation if deliverables not met |

---

## Risk Response Decision Tree

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  RESPONSE DECISION TREE                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Impact │ Probability │ Response Strategy                                  │
│  ───────┼─────────────┼───────────────────────────────────────────────────  │
│   P0    │  Probable   │ AVOID: Change approach, remove feature, or         │
│         │             │        escalate to stakeholders immediately          │
│  ───────┼─────────────┼───────────────────────────────────────────────────  │
│   P0    │  Possible   │ MITIGATE: Proactive monitoring, fallback plans,  │
│   P1    │  Probable   │            dedicated owner assigned                  │
│  ───────┼─────────────┼───────────────────────────────────────────────────  │
│   P1    │  Possible   │ MONITOR: Track in risk register, review weekly     │
│   P2    │  Probable   │                                                      │
│  ───────┼─────────────┼───────────────────────────────────────────────────  │
│   P2    │  Possible   │ ACCEPT: Document and continue, no active action    │
│   P3    │  Any        │                                                      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Risk Validation Checklist

```
□ Risk Register created (minimum 5 risks identified)
□ Each risk has owner assigned
□ P0/P1 risks have active mitigation plan
□ Risk acceptance criteria documented for "Accepted" risks
□ Weekly risk review scheduled for first 4 sprints
□ Risk status updated in user story YAML files
□ Stakeholders aware of all P0/P1 risks
```

---

## Risk YAML Schema Extension

Add to your `spec-ddd/feat-XXX.yml`:

```yaml
risks:
  identified:
    - id: "R-001"
      description:
        es: "Descripción del riesgo en español"
        en: "Risk description in English"
      probability: "probable|possible|unlikely"
      impact: "P0|P1|P2|P3"
      mitigation:
        es: "Estrategia de mitigación"
        en: "Mitigation strategy"
      owner: "[team/person responsible]"
      status: "open|mitigated|accepted|closed"
```

---

## Related Resources

- [DDD Pattern Library](ddd-pattern-library.md)
- [DDD Tactics](ddd-tactics.md)
- [Back to SKILL.md](../SKILL.md)
