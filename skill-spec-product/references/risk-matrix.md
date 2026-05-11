# Risk Matrix Reference

> **PRINCIPLE**: "What can go wrong, will go wrong. Document it before it documents you."

Quick reference for identifying and mitigating risks in product specification and delivery.

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
RISK REGISTER - Project: [Name] - Date: [YYYY-MM-DD]

ID    │ RISK DESCRIPTION          │ PROBABILITY │ IMPACT │ LEVEL │ STATUS
──────┼───────────────────────────┼─────────────┼────────┼───────┼─────────
R-001 │ [Technical/Business/Process] │ [P/U]       │ [P0-3] │ [C/W/A]│ [O/C]
R-002 │                           │             │        │       │
R-003 │                           │             │        │       │

Legend:
- Probability: Pr=Probable, Po=Possible, U=Unlikely
- Level: C=Critical, W=Warning, A=Accepted
- Status: O=Open, C=Closed, M=Mitigated
```

---

## Risk Categories for Product Delivery

### Technical Risks

| ID | Risk Area | Risk Description | Mitigation Strategy |
|----|-----------|------------------|---------------------|
| T-001 | **Spec Drift** | YAML specs become outdated vs. actual build | CI validation: specs must be updated before PR merge |
| T-002 | **Complexity Underestimation** | User story effort hours significantly off | Always use 3-point estimation; add 30% buffer |
| T-003 | **Integration Failures** | External systems don't match spec contracts | Contract testing (Pact/OpenAPI) |
| T-004 | **Performance at Scale** | Feature doesn't handle projected load | Load testing in Sprint 0; performance budgets in YAML |
| T-005 | **Design-Dev Gap** | Designs don't match what engineering can build | Design review with engineering before spec finalization |
| T-006 | **Third-Party Dependency** | External API or service changes or goes down | Abstraction interfaces; fallback plans |

### Business Risks

| ID | Risk Area | Risk Description | Mitigation Strategy |
|----|-----------|------------------|---------------------|
| B-001 | **Stakeholder Misalignment** | Business language in specs does not match actual needs | Stakeholder sign-off on acceptance criteria |
| B-002 | **Priority Conflicts** | P0 stories compete for same resources | WSJF scoring in YAML; capacity planning per sprint |
| B-003 | **Regulatory Changes** | Compliance requirements shift mid-project | Quarterly legal review checkpoint |
| B-004 | **Vendor Lock-in** | External system dependencies become blockers | Abstraction interfaces for external services |
| B-005 | **ROI Unclear** | Cost savings/revenue impact estimates wrong | Real metrics tracking vs. YAML predictions; monthly review |

### Process Risks

| ID | Risk Area | Risk Description | Mitigation Strategy |
|----|-----------|------------------|---------------------|
| P-001 | **Git Convention Fatigue** | Team stops following branch/commit conventions | Pre-commit hooks validation; CI rejects non-compliant PRs |
| P-002 | **YAML Schema Errors** | Invalid YAML structure breaks traceability | JSON Schema validation in CI; editor plugins with autocomplete |
| P-003 | **Analysis Paralysis** | Stuck in discovery/analysis phases | Time-boxed phases (2 weeks max); "good enough" criteria upfront |
| P-004 | **Knowledge Silos** | Only one person understands the specs | Mandatory peer review for specification; docs in repo |
| P-005 | **Traceability Breakdown** | Commits lose connection to user stories | Git hooks enforcing commit message format; story_id in metadata |
| P-006 | **Sprint 0 Never Ends** | Foundation phase extends indefinitely | Fixed 2-week Sprint 0 with clear DoD; escalation if deliverables not met |

---

## Risk Response Decision Tree

```
RESPONSE DECISION TREE

Impact │ Probability │ Response Strategy
───────┼─────────────┼───────────────────────────────────────────────────
  P0   │  Probable   │ AVOID: Change approach, remove feature, or
       │             │        escalate to stakeholders immediately
───────┼─────────────┼───────────────────────────────────────────────────
  P0   │  Possible   │ MITIGATE: Proactive monitoring, fallback plans,
  P1   │  Probable   │            dedicated owner assigned
───────┼─────────────┼───────────────────────────────────────────────────
  P1   │  Possible   │ MONITOR: Track in risk register, review weekly
  P2   │  Probable   │
───────┼─────────────┼───────────────────────────────────────────────────
  P2   │  Possible   │ ACCEPT: Document and continue, no active action
  P3   │  Any        │
```

---

## Risk Validation Checklist

- [ ] Risk Register created (minimum 5 risks identified)
- [ ] Each risk has owner assigned
- [ ] P0/P1 risks have active mitigation plan
- [ ] Risk acceptance criteria documented for "Accepted" risks
- [ ] Weekly risk review scheduled for first 4 sprints
- [ ] Risk status updated in user story YAML files
- [ ] Stakeholders aware of all P0/P1 risks

---

## Risk YAML Schema Extension

Add to your `spec-product/feat-XXX.yml`:

```yaml
risks:
  identified:
    - id: "R-001"
      description: "Risk description in English"
      probability: "probable|possible|unlikely"
      impact: "P0|P1|P2|P3"
      mitigation: "Mitigation strategy"
      owner: "[team/person responsible]"
      status: "open|mitigated|accepted|closed"
```

---

## Related Resources

- [Back to SKILL.md](../SKILL.md)
