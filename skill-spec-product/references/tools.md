# Tools & Software

> **Recommended tools for each phase of Product Spec-Driven Delivery.**

---

## Discovery & Intake

### Whiteboarding & Collaboration

| Tool | Type | Best For | Cost |
|------|------|----------|------|
| **Miro** | Online Whiteboard | Remote teams, discovery workshops | Freemium |
| **Mural** | Online Whiteboard | Enterprise, facilitators | Paid |
| **FigJam** | Online Whiteboard | Design-centric teams, Figma users | Freemium |
| **Notion** | Docs + Whiteboard | Notes, wikis, light collaboration | Freemium |

**Recommended:** Miro for remote workshops, FigJam for design-led teams.

---

## Prioritization & Roadmapping

| Tool | Type | Best For |
|------|------|----------|
| **Linear** | Issue Tracking | Modern product teams, fast workflows |
| **Jira** | Project Management | Enterprise, complex workflows |
| **Productboard** | Product Management | Feature prioritization, feedback collection |
| **Aha!** | Roadmapping | Large product orgs, formal roadmaps |
| **Notion** | Docs + Database | Lightweight roadmaps, small teams |

**Recommended:** Linear for most teams; Productboard if you need user feedback integration.

---

## Specification & Documentation

### YAML & Spec Tools

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
    "schema/user-story.schema.json": "spec-product/*.yml"
  },
  "yaml.customTags": [
    "!story",
    "!product"
  ]
}
```

### Design & Flow Documentation

| Tool | Type | Best For |
|------|------|----------|
| **Figma** | Design | UI mockups, prototypes, design systems |
| **Whimsical** | Diagrams | User flows, wireframes, sitemaps |
| **Miro** | Whiteboard | Service blueprints, journey maps |
| **Confluence** | Wiki | Long-form specs, decision logs |
| **Notion** | Docs | Living specs, databases, wikis |

---

## Validation & Review

### Collaboration & Sign-off

| Tool | Purpose |
|------|---------|
| **Loom** | Async video | Walkthroughs for remote stakeholders |
| **Figma** | Comments | Design review threads |
| **Google Docs** | Comments | Draft review, lightweight feedback |
| **Slack** | Messaging | Quick decisions, async standups |

---

## Handoff & Delivery

### Engineering Collaboration

| Tool | Purpose |
|------|---------|
| **GitHub** | Repo + Issues | Code, PRs, issue tracking |
| **GitLab** | Repo + CI/CD | Integrated DevOps |
| **Linear** | Issue Tracking | Connects specs to engineering tickets |
| **Jira** | Project Management | Sprint planning, burndown |
| **Slack** | Messaging | Daily comms, alerts |
| **Confluence** | Wiki | Engineering context docs |

---

## Recommended Tool Stack

### Minimal Setup (Start Here)
```
Discovery:     Miro (free tier) or FigJam
Prioritization: Notion or Linear (free tier)
Specs:         VS Code + YAML extension
Design:        Figma (free tier)
Handoff:       Linear or GitHub Issues
Docs:          Notion or Markdown in repo
```

### Professional Setup
```
Discovery:     Miro + User research tools
Prioritization: Linear or Productboard
Specs:         VS Code + yamllint + JSON Schema
Design:        Figma + Whimsical
Handoff:       Linear + GitHub + Slack
Docs:          Notion + Confluence
```

### Enterprise Setup
```
Discovery:     Mural + Facilitation training
Prioritization: Aha! + Jira
Specs:         Custom schema validation + CI
Design:        Figma Enterprise + design system
Handoff:       Jira + Confluence + Slack Enterprise
Docs:          Confluence + custom workflows
```

---

## Tool Integration Checklist

- [ ] YAML validation in IDE (VS Code extension)
- [ ] Pre-commit hooks for commit message format
- [ ] CI pipeline rejects non-compliant commits
- [ ] Specs directory (`spec-product/`) in version control
- [ ] Story traceability from spec to engineering ticket
- [ ] Design files linked in spec YAMLs

---

## Related Resources

- [Books](books.md) - For tool selection theory
- [Back to SKILL.md](../SKILL.md)
