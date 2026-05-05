---
name: skill-spec-ddd
description: >-
  Spec-Driven Development (SDD) framework powered by Domain-Driven Design (DDD) patterns.
  Enterprise-grade system development guided by executable specifications (YAML user stories)
  with full traceability from requirements to code. Following FANG-level engineering practices
  for scalable, maintainable architectures where specs are the source of truth.
compatibility: Framework agnostic. Works with Node.js, Python, Java, Go, .NET, PHP, etc.
metadata:
  author: leifermendez
  version: "1.0.0"
  tags: "ddd, domain-driven-design, fang, system-design, architecture, microservices, bounded-contexts"
---

# skill-spec-ddd

## 🎯 Phase 1: Requirements Elicitation (Discovery)

> **ROLE ACTIVATION**: You are now operating as a **Senior Stack Engineer** with FANG-level expertise. 
> Your mandate: Build systems that handle millions of requests, scale horizontally, and remain maintainable for years.

### Step 1.1: Mandatory Discovery (Minimum 3)

**INSTRUCTION**: Before ANY analysis or solution, you MUST collect the following from the user. 
Ask clarifying questions until you have at least 3 items in EACH category.

---

#### 📍 SCOPE (Alcance - Es/En)
Define WHAT we are building. Boundaries of the system.

| # | Question (ES) | Question (EN) | Input |
|---|---------------|---------------|-------|
| 1 | ¿Cuál es el objetivo principal del sistema? | What is the primary goal of the system? | |
| 2 | ¿Qué funcionalidades están INCLUIDAS explícitamente? | What functionalities are EXPLICITLY INCLUDED? | |
| 3 | ¿Qué funcionalidades están EXCLUIDAS explícitamente? | What functionalities are EXPLICITLY EXCLUDED? | |
| 4 | ¿Cuáles son los límites geográficos/mercado objetivo? | What are the geographic/market boundaries? | |
| 5 | ¿Qué integraciones externas son requeridas? | What external integrations are required? | |

**Minimum 3 scopes documented before proceeding.**

---

#### 📐 ALCANCE TÉCNICO / TECHNICAL SCOPE (Es/En)
Define the technical boundaries and constraints.

| # | Question (ES) | Question (EN) | Input |
|---|---------------|---------------|-------|
| 1 | ¿Cuál es el volumen esperado de usuarios/transacciones? | What is the expected user/transaction volume? | |
| 2 | ¿Cuáles son los requisitos de latencia/SLA? | What are the latency/SLA requirements? | |
| 3 | ¿Hay restricciones tecnológicas (stack obligatorio)? | Are there mandatory technology stack constraints? | |
| 4 | ¿Cuáles son los requisitos de disponibilidad (uptime %)? | What are the availability requirements (uptime %)? | |
| 5 | ¿Qué requisitos de compliance existen (GDPR, HIPAA, PCI)? | What compliance requirements exist? | |
| 6 | ¿Cuál es el presupuesto aproximado para infraestructura? | What is the approximate infrastructure budget? | |

**Minimum 3 technical scopes documented before proceeding.**

---

#### 😫 PUNTOS DE DOLOR / PAIN POINTS (Es/En)
Identify current or anticipated problems.

| # | Question (ES) | Question (EN) | Input |
|---|---------------|---------------|-------|
| 1 | ¿Qué problemas críticos enfrenta actualmente el negocio? | What critical business problems are currently faced? | |
| 2 | ¿Dónde se pierde más tiempo/recursos manualmente? | Where is the most time/resources lost manually? | |
| 3 | ¿Qué errores recurrentes impactan operaciones/ingresos? | What recurring errors impact operations/revenue? | |
| 4 | ¿Qué procesos no escalan con el crecimiento actual? | What processes don't scale with current growth? | |
| 5 | ¿Cuáles son las quejas más frecuentes de usuarios/clientes? | What are the most frequent user/customer complaints? | |
| 6 | ¿Qué competidores hacen mejor que ustedes actualmente? | What do competitors do better than you currently? | |

**Minimum 3 pain points documented before proceeding.**

---

### Step 1.2: Stakeholder Mapping

Map who cares about this system:

```
┌─────────────────────────────────────────────────────────┐
│  STAKEHOLDER MAP                                        │
├─────────────────────────────────────────────────────────┤
│  Primary Users:     [End users of the system]           │
│  Secondary Users:   [Internal staff, admins]          │
│  Decision Makers:   [Executives, product owners]      │
│  Blockers/Risks:    [Legal, compliance, security]      │
│  Integrators:       [External systems, partners]      │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 Phase 1.3: User Stories Generation (Automated)

> **INSTRUCTION**: After collecting requirements, IMMEDIATELY create user story specifications.

### Automated Output

**ALWAYS** create the following structure after Phase 1:
### File Naming Convention

```
spec-ddd/
├── feat-001-discovery.yml          # Summary of discovery phase
├── feat-002-scope-[name].yml       # Per scope item (min 3)
├── feat-003-tech-[name].yml        # Per technical scope (min 3)
├── feat-004-pain-[name].yml        # Per pain point (min 3)
└── feat-005-aggregate-[name].yml   # Per identified aggregate
```

**Rules:**
- Use sequential numbering: `feat-001`, `feat-002`, etc.
- Use kebab-case for descriptive names
- Maximum 50 characters in filename

---

### 🌿 Git Naming Conventions

All user stories MUST include Git branch, commit, and PR naming conventions for traceability.

#### Branch Naming

```
Format:    <type>/feat-<XXX>-<short-description>

Examples:
  feat/feat-002-user-registration
  feat/feat-003-invoice-automation
  fix/feat-002-email-verification-bug
  refactor/feat-006-order-aggregate

Types:
  feat/     - New feature implementation
  fix/      - Bug fix related to a user story
  refactor/ - Code refactoring without behavior change
  test/     - Adding/updating tests for a user story
  docs/     - Documentation updates for a feature
```

**Rules:**
- Always include the feature ID: `feat-XXX`
- Keep description under 50 characters
- Use kebab-case (hyphens between words)
- No underscores, no camelCase in branch names

#### Commit Message Convention

```
Format:    <type>(feat-XXX): <description>

Examples:
  feat(feat-002): implement user registration aggregate
  feat(feat-002): add email verification service
  fix(feat-003): correct tax calculation for EU customers
  test(feat-002): add unit tests for User aggregate
  docs(feat-002): update API documentation

Types:
  feat(feat-XXX):     - New feature code
  fix(feat-XXX):      - Bug fix
  refactor(feat-XXX): - Code restructuring
  test(feat-XXX):     - Test addition/updates
  docs(feat-XXX):     - Documentation
  chore(feat-XXX):    - Maintenance, deps, etc.
```

**Rules:**
- ALWAYS include feature ID in parentheses: `(feat-XXX)`
- Use imperative mood: "add" not "added", "fix" not "fixed"
- First letter lowercase
- No period at the end
- Maximum 72 characters in subject line

#### PR (Pull Request) Naming

```
Format:    <type>(feat-XXX): <Short Description>

Examples:
  feat(feat-002): User Registration with Email Verification
  feat(feat-003): Automated Invoice Generation from Orders
  fix(feat-002): Handle Duplicate Email Edge Case
  refactor(feat-006): Extract Payment Service from Order Aggregate

Template for PR Description:
  ## Related User Story
  Closes spec-ddd/feat-XXX.yml

  ## Changes
  - [List of changes]

  ## Acceptance Criteria Verified
  - [x] AC-01: [description]
  - [x] AC-02: [description]

  ## Testing
  - [How this was tested]
```

#### Full Traceability Example

```
User Story YAML: spec-ddd/feat-002-user-registration.yml
         │
         ├── Branch:  feat/feat-002-user-registration
         │            ├── Commit: feat(feat-002): implement User aggregate root
         │            ├── Commit: feat(feat-002): add EmailVerification entity
         │            ├── Commit: test(feat-002): add User aggregate unit tests
         │            └── Commit: feat(feat-002): integrate with SendGrid email service
         │
         ├── PR:      feat(feat-002): User Registration with Email Verification
         │            └── Links to: spec-ddd/feat-002-user-registration.yml
         │
         └── Merge:   Squash merge to main with PR title as commit
                      └── Commit on main: feat(feat-002): User Registration with Email Verification

Result: Full traceability from code commit → PR → User Story YAML → Domain Context
```

#### Git Workflow Commands

```bash
# 1. Create branch from user story
git checkout -b feat/feat-002-user-registration

# 2. Make changes and commit with convention
git commit -m "feat(feat-002): implement User aggregate root"
git commit -m "test(feat-002): add unit tests for email verification"

# 3. Push and create PR
git push origin feat/feat-002-user-registration
# Create PR with title: feat(feat-002): User Registration with Email Verification
# Reference: spec-ddd/feat-002-user-registration.yml

# 4. After merge, update user story status
git checkout main
git pull origin main
```

#### Validation Checklist for Git Naming

- [ ] Branch starts with type: `feat/`, `fix/`, `refactor/`, etc.
- [ ] Branch includes feature ID: `feat-XXX`
- [ ] Branch uses kebab-case, no underscores
- [ ] Branch name under 50 characters
- [ ] Commits include feature ID in parentheses: `(feat-XXX)`
- [ ] Commit messages use imperative mood
- [ ] Commit subject under 72 characters
- [ ] PR title includes feature ID: `(feat-XXX)`
- [ ] PR description links to YAML file: `spec-ddd/feat-XXX.yml`
- [ ] PR includes acceptance criteria checklist

### User Story YAML Schema

Each `.yml` file MUST follow this structure:

```yaml
# spec-ddd/feat-XXX-name.yml
story:
  id: "feat-XXX"                    # Sequential ID
  type: "discovery|scope|technical|pain|aggregate|use-case"
  status: "draft|refined|ready|done"
  
  # User Story Statement
  as_a: "[role]"                    # Who
  i_want: "[goal/action]"         # What
  so_that: "[benefit/value]"      # Why
  
  # Dual Language
  description:
    es: "Descripción en español"
    en: "Description in English"
  
  # DDD Context
  domain:
    bounded_context: "[ContextName]"
    aggregate: "[AggregateName]"
    entities: ["Entity1", "Entity2"]
    value_objects: ["ValueObject1"]
    domain_events: ["Event1Occurred", "Event2Completed"]
  
  # Acceptance Criteria
  acceptance_criteria:
    - id: "ac-01"
      given: "[precondition]"
      when: "[action]"
      then: "[expected result]"
      es:
        dado: "[precondición]"
        cuando: "[acción]"
        entonces: "[resultado esperado]"
    
  # Technical Scope
  technical:
    complexity: "low|medium|high|critical"
    effort_hours: "[estimated hours]"
    impact: "low|medium|high"
    risks:
      - id: "risk-01"
        description: "Risk description"
        mitigation: "How to mitigate"
    
  # Business Value
  business:
    priority: "P0|P1|P2|P3"
    kpis_impacted:
      - "[KPI name]"
    revenue_impact: "[estimate]"
    cost_savings: "[estimate]"
    
  # Dependencies
  dependencies:
    stories: ["feat-001", "feat-002"]  # IDs of dependent stories
    systems: ["External API", "Database"]
    teams: ["Team A", "Team B"]
  
  # Notes
  notes:
    - "[Additional context]"
    
  # Git / Version Control
  git:
    branch_name: "feat/feat-XXX-short-description"  # Branch naming convention
    commit_prefix: "feat(feat-XXX):"                  # Commit message prefix
    pr_title: "feat(feat-XXX): Short description"   # PR title format
    related_commits: []                              # Auto-populated during dev
  
  # Metadata
  metadata:
    created_at: "YYYY-MM-DD"
    updated_at: "YYYY-MM-DD"
    author: "[name]"
    source: "discovery|stakeholder|analysis"
```

### Example User Story Files

**Example 1: Discovery Summary**
```yaml
# spec-ddd/feat-001-discovery.yml
story:
  id: "feat-001"
  type: "discovery"
  status: "done"
  
  as_a: "System Architect"
  i_want: "Document all discovery findings"
  so_that: "We have a clear baseline for design decisions"
  
  description:
    es: "Resumen de la fase de descubrimiento con 3+ scopes, alcances técnicos y puntos de dolor identificados"
    en: "Summary of discovery phase with 3+ scopes, technical scopes and pain points identified"
  
  domain:
    bounded_context: "N/A - Discovery Phase"
  
  acceptance_criteria:
    - id: "ac-01"
      given: "Discovery phase completed"
      when: "All stakeholders interviewed"
      then: "Minimum 3 scopes documented"
      es:
        dado: "Fase de descubrimiento completada"
        cuando: "Todos los stakeholders entrevistados"
        entonces: "Mínimo 3 scopes documentados"
  
  metadata:
    created_at: "2024-01-15"
    author: "System"
    source: "discovery"
```

**Example 2: Scope Item**
```yaml
# spec-ddd/feat-002-user-registration.yml
story:
  id: "feat-002"
  type: "scope"
  status: "refined"
  
  as_a: "New Customer"
  i_want: "Register for an account with email verification"
  so_that: "I can securely access the platform features"
  
  description:
    es: "Sistema de registro de usuarios con verificación por email, validación de datos y prevención de duplicados"
    en: "User registration system with email verification, data validation and duplicate prevention"
  
  domain:
    bounded_context: "IdentityManagement"
    aggregate: "User"
    entities: ["User", "EmailVerification"]
    value_objects: ["Email", "Password", "VerificationToken"]
    domain_events: ["UserRegistered", "EmailVerificationSent", "EmailVerified"]
  
  acceptance_criteria:
    - id: "ac-01"
      given: "Valid email and password provided"
      when: "User submits registration form"
      then: "Account is created and verification email sent"
      es:
        dado: "Email y contraseña válidos proporcionados"
        cuando: "Usuario envía formulario de registro"
        entonces: "Cuenta creada y email de verificación enviado"
    
    - id: "ac-02"
      given: "Email already exists in system"
      when: "User attempts registration"
      then: "System shows error without revealing existing account"
      es:
        dado: "Email ya existe en el sistema"
        cuando: "Usuario intenta registrarse"
        entonces: "Sistema muestra error sin revelar cuenta existente"
  
  technical:
    complexity: "medium"
    effort_hours: "24"
    impact: "high"
    risks:
      - id: "risk-01"
        description: "Email delivery failures"
        mitigation: "Implement retry logic and fallback SMS"
  
  business:
    priority: "P0"
    kpis_impacted: ["User Acquisition", "Activation Rate"]
    revenue_impact: "High - entry point for all users"
  
  dependencies:
    stories: ["feat-001"]
    systems: ["Email Service", "Database"]
  
  metadata:
    created_at: "2024-01-15"
    updated_at: "2024-01-15"
    author: "System"
    source: "discovery"
```

**Example 3: Pain Point**
```yaml
# spec-ddd/feat-004-manual-invoicing.yml
story:
  id: "feat-004"
  type: "pain"
  status: "draft"
  
  as_a: "Finance Team Member"
  i_want: "Automated invoice generation from completed orders"
  so_that: "I can eliminate manual data entry errors and reduce processing time by 80%"
  
  description:
    es: "Automatización de facturación para eliminar procesos manuales que causan errores y retrasos"
    en: "Invoice automation to eliminate manual processes causing errors and delays"
  
  domain:
    bounded_context: "Billing"
    aggregate: "Invoice"
    entities: ["Invoice", "InvoiceLine"]
    value_objects: ["Money", "TaxRate", "InvoiceNumber"]
    domain_events: ["InvoiceGenerated", "InvoiceSent", "PaymentReceived"]
  
  acceptance_criteria:
    - id: "ac-01"
      given: "Order status changes to completed"
      when: "End of day batch runs"
      then: "Invoice is automatically generated and queued for sending"
      es:
        dado: "Estado de orden cambia a completado"
        cuando: "Batch de fin de día ejecuta"
        entonces: "Factura generada automáticamente y en cola de envío"
  
  business:
    priority: "P1"
    kpis_impacted: ["Processing Time", "Error Rate", "Cash Flow"]
    cost_savings: "$50K/year in manual labor"
  
  metadata:
    created_at: "2024-01-15"
    author: "System"
    source: "discovery"
```

---

## 🧠 Phase 2: Dual-Language Analysis (Es/En)

> **ROLE**: Senior Systems Architect analyzing requirements for FANG-scale implementation.

### Step 2.1: Scope Analysis Matrix

For EACH scope item collected, produce analysis in BOTH languages:

**Template for each scope item:**

```
┌────────────────────────────────────────────────────────────────────────────┐
│  SCOPE ITEM #[N]: [Title]                                                  │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  🇪🇸 ANÁLISIS (ES):                                                        │
│  ─────────────────                                                         │
│  • Impacto en dominio: [¿Qué bounded contexts afecta?]                     │
│  • Complejidad técnica: [Baja/Media/Alta/Crítica]                          │
│  • Riesgos identificados: [Lista de riesgos]                              │
│  • Suposiciones clave: [Assumptions made]                                 │
│  • Métricas de éxito: [Cómo medimos el cumplimiento]                      │
│                                                                            │
│  🇺🇸 ANALYSIS (EN):                                                        │
│  ─────────────────                                                         │
│  • Domain Impact: [Which bounded contexts are affected?]                   │
│  • Technical Complexity: [Low/Medium/High/Critical]                      │
│  • Identified Risks: [List of risks]                                       │
│  • Key Assumptions: [Assumptions made]                                     │
│  • Success Metrics: [How we measure fulfillment]                          │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

### Step 2.2: Technical Scope Analysis Matrix

```
┌────────────────────────────────────────────────────────────────────────────┐
│  TECHNICAL ITEM #[N]: [Title]                                             │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  🇪🇸 ANÁLISIS TÉCNICO (ES):                                                │
│  ─────────────────────────                                                 │
│  • Arquitectura recomendada: [Monolito modular/Microservicios/Híbrido]    │
│  • Patrones aplicables: [CQRS, Event Sourcing, Saga, etc.]              │
│  • Estrategia de escalado: [Vertical/Horizontal/Auto-scaling]             │
│  • Trade-offs: [Compromisos aceptados]                                    │
│  • Costo estimado: [Back-of-envelope calculation]                         │
│                                                                            │
│  🇺🇸 TECHNICAL ANALYSIS (EN):                                             │
│  ─────────────────────────                                                 │
│  • Recommended Architecture: [Modular monolith/Microservices/Hybrid]      │
│  • Applicable Patterns: [CQRS, Event Sourcing, Saga, etc.]               │
│  • Scaling Strategy: [Vertical/Horizontal/Auto-scaling]                 │
│  • Trade-offs: [Accepted compromises]                                    │
│  • Estimated Cost: [Back-of-envelope calculation]                         │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

### Step 2.3: Pain Point Analysis Matrix

```
┌────────────────────────────────────────────────────────────────────────────┐
│  PAIN POINT #[N]: [Title]                                                 │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  🇪🇸 ANÁLISIS DE DOLOR (ES):                                               │
│  ──────────────────────────                                                │
│  • Severidad: [Crítica/Alta/Media/Baja]                                   │
│  • Frecuencia: [Constante/Frecuente/Ocasional/Rara]                       │
│  • Impacto financiero: [Estimación de pérdida/costo]                    │
│  • Dominio afectado: [Bounded context relacionado]                      │
│  • Solución DDD propuesta: [Aggregate/Entity/Service que resuelve]        │
│  • Prioridad: [P0 (bloqueante) / P1 (alta) / P2 (media) / P3 (baja)]   │
│                                                                            │
│  🇺🇸 PAIN POINT ANALYSIS (EN):                                            │
│  ──────────────────────────                                                │
│  • Severity: [Critical/High/Medium/Low]                                   │
│  • Frequency: [Constant/Frequent/Occasional/Rare]                         │
│  • Financial Impact: [Estimated loss/cost]                              │
│  • Affected Domain: [Related bounded context]                             │
│  • Proposed DDD Solution: [Aggregate/Entity/Service that solves]          │
│  • Priority: [P0 (blocking) / P1 (high) / P2 (medium) / P3 (low)]         │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔨 Phase 3: Problem Decomposition (Stack Engineer FANG Approach)

> **PRINCIPLE**: "Divide and conquer. A problem well-defined is a problem half-solved."

### Step 3.1: The FANG Problem Splitting Framework

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  🔥 FANG PROBLEM DECOMPOSITION                                               │
│                                                                              │
│  "How would Amazon handle this? How would Netflix scale this?"              │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  LAYER 1: STRATEGIC DECOMPOSITION (The "Why")                               │
│  ────────────────────────────────────────────                               │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  BUSINESS CAPABILITY MAPPING                                        │   │
│  │                                                                     │   │
│  │  [Capability 1] ───────┐                                            │   │
│  │  [Capability 2] ──────┼───> Core Domain                            │   │
│  │  [Capability 3] ──────┘                                            │   │
│  │                                                                     │   │
│  │  [Capability 4] ───────┐                                            │   │
│  │  [Capability 5] ──────┼───> Supporting Domain                      │   │
│  │  [Capability 6] ──────┘                                            │   │
│  │                                                                     │   │
│  │  [Capability 7] ───────┐                                            │   │
│  │  [Capability 8] ──────┼───> Generic Domain                         │   │
│  │  [Capability 9] ──────┘                                            │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  LAYER 2: TACTICAL DECOMPOSITION (The "What")                              │
│  ───────────────────────────────────────────                               │
│                                                                              │
│  For EACH Business Capability, decompose into:                              │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  BOUNDED CONTEXT IDENTIFICATION                                     │   │
│  │                                                                     │   │
│  │  Context: [Name]                                                    │   │
│  │  ├── Ubiquitous Language: [Domain-specific terms]                  │   │
│  │  ├── Aggregates: [Large consistency boundaries]                     │   │
│  │  ├── Entities: [Objects with identity]                             │   │
│  │  ├── Value Objects: [Immutable descriptors]                        │   │
│  │  ├── Domain Events: [Significant occurrences]                      │   │
│  │  └── Domain Services: [Operations not belonging to entities]       │   │
│  │                                                                     │   │
│  │  Integration Patterns: [API/Events/Shared Kernel]                  │   │
│  │  Team Ownership: [Which team owns this]                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  LAYER 3: IMPLEMENTATION DECOMPOSITION (The "How")                          │
│  ────────────────────────────────────────────────                           │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  SUBDOMAIN ARCHITECTURE                                             │   │
│  │                                                                     │   │
│  │  [Subdomain A]                                                      │   │
│  │  ├── Module: [feature-module]                                       │   │
│  │  │   ├── Application Layer                                         │   │
│  │  │   │   ├── Use Cases/Commands                                     │   │
│  │  │   │   ├── Queries (if CQRS)                                      │   │
│  │  │   │   └── DTOs                                                   │   │
│  │  │   ├── Domain Layer                                               │   │
│  │  │   │   ├── Aggregates                                            │   │
│  │  │   │   ├── Entities                                              │   │
│  │  │   │   ├── Value Objects                                          │   │
│  │  │   │   ├── Domain Events                                          │   │
│  │  │   │   ├── Repositories (interfaces)                              │   │
│  │  │   │   └── Domain Services                                        │   │
│  │  │   └── Infrastructure Layer                                       │   │
│  │  │       ├── Repository Implementations                             │   │
│  │  │       ├── External Services Clients                              │   │
│  │  │       ├── Event Publishers/Subscribers                           │   │
│  │  │       └── Persistence Mappers                                    │   │
│  │  └── Interface Layer                                                │   │
│  │      ├── Controllers/Handlers                                       │   │
│  │      ├── Presenters/ViewModels                                      │   │
│  │      └── Input Validators                                           │   │
│  │                                                                     │   │
│  │  [Subdomain B] ...                                                 │   │
│  │  [Subdomain C] ...                                                 │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Step 3.2: Dependency Analysis

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DEPENDENCY GRAPH (Context Map)                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│     ┌───────────┐         Customer/Supplier         ┌───────────┐         │
│     │ Context A │◄──────────────────────────────────►│ Context B │         │
│     │  (Upstream)│                                    │ (Downstream)│       │
│     └─────┬─────┘                                    └───────────┘         │
│           │                                                                  │
│           │ Published Language                                               │
│           ▼                                                                  │
│     ┌───────────┐         Shared Kernel          ┌───────────┐              │
│     │ Context C │◄═══════════════════════════════►│ Context D │              │
│     └───────────┘                                └───────────┘              │
│                                                                              │
│     ┌───────────┐         Anti-Corruption Layer    ┌───────────┐            │
│     │ Legacy E │◄────────────[ACL]─────────────────│ Context F │            │
│     │  System   │                                  │  (New)    │            │
│     └───────────┘                                  └───────────┘            │
│                                                                              │
│     ┌───────────┐         Open Host Service        ┌───────────┐            │
│     │ Context G │◄───────────[OHS]────────────────│ Context H │            │
│     │  (Generic)│         (Standard Protocol)      │ (Consumer)│            │
│     └───────────┘                                  └───────────┘            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Step 3.3: Event Storming Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DOMAIN EVENT CHAIN (Chronological)                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Actor          Command              Aggregate          Event              │
│  ─────────────────────────────────────────────────────────────────────────  │
│  [User]    ──> [Action]   ──> [Entity]   ──> [DomainEvent]                 │
│                                                                              │
│  Timeline:                                                                  │
│                                                                              │
│  Time ─────────────────────────────────────────────────────────────►      │
│                                                                              │
│  [Event 1] ──► [Event 2] ──► [Event 3] ──► [Event 4] ──► [Event 5]          │
│     │            │            │            │            │                    │
│     ▼            ▼            ▼            ▼            ▼                    │
│  Policy 1    Policy 2    External      Read      External                 │
│  Trigger     Trigger     System        Model       System                  │
│                          Update        Update      Notification             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Phase 4: Architecture Decision Records (ADRs)

> **FANG Principle**: "Decisions must be documented, reversible, and evidence-based."

### ADR Template (Mandatory for each major decision)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ADR #[NNN]: [Title]                                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Status: [PROPOSED | ACCEPTED | DEPRECATED | SUPERSEDED]                   │
│  Date: [YYYY-MM-DD]                                                         │
│  Deciders: [Names/Teams]                                                    │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                                                              │
│  CONTEXT (The problem we're solving)                                        │
│  ────────                                                                   │
│  [What is the issue that we're seeing that is motivating this decision?]   │
│                                                                              │
│  DECISION (What we're doing)                                                │
│  ──────────                                                                 │
│  [What is the change that we're proposing or have agreed to implement?]    │
│                                                                              │
│  CONSEQUENCES (What happens as a result)                                    │
│  ────────────                                                               │
│  • Positive: [Benefits]                                                      │
│  • Negative: [Trade-offs and costs]                                        │
│  • Neutral: [Other effects]                                                  │
│                                                                              │
│  ALTERNATIVES CONSIDERED (Why not X?)                                       │
│  ──────────────────────────                                                 │
│  • [Alternative 1]: [Why rejected]                                          │
│  • [Alternative 2]: [Why rejected]                                          │
│                                                                              │
│  EVIDENCE (Data backing this decision)                                      │
│  ────────                                                                   │
│  • [Load testing results]                                                   │
│  • [Proof of concept outcome]                                               │
│  • [Industry benchmarks]                                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Required ADRs for DDD Projects

| # | ADR Topic | Trigger Condition |
|---|-----------|-------------------|
| 001 | Architecture Style (Monolith vs Microservices) | Always required |
| 002 | Data Persistence Strategy | If database involved |
| 003 | Communication Patterns (Sync vs Async) | If multiple contexts |
| 004 | Event Sourcing vs State Storage | If domain events critical |
| 005 | CQRS Implementation | If read/write patterns differ |
| 006 | API Style (REST vs GraphQL vs gRPC) | If external API exposed |
| 007 | Authentication/Authorization Strategy | Always required |
| 008 | Testing Strategy | Always required |

---

## 📋 Phase 5: Implementation Checklist (FANG Standards)

### Pre-Implementation Verification

```
□ Discovery Phase Complete
  □ Minimum 3 scopes documented
  □ Minimum 3 technical scopes documented  
  □ Minimum 3 pain points documented
  □ Stakeholder map created
  □ User Story YAML files created in spec-ddd/

□ Analysis Phase Complete
  □ All scopes analyzed (ES/EN)
  □ All technical scopes analyzed (ES/EN)
  □ All pain points analyzed (ES/EN)
  □ User stories refined with acceptance criteria

□ Decomposition Phase Complete
  □ Business capabilities mapped
  □ Bounded contexts identified
  □ Ubiquitous language defined per context
  □ Aggregates designed
  □ Domain events catalogued
  □ Context map drawn
  □ User stories mapped to aggregates

□ Architecture Phase Complete
  □ ADRs written for major decisions
  □ Technology stack selected
  □ Infrastructure requirements defined
  □ Security model designed
  □ Observability strategy defined (logs/metrics/traces)

□ Planning Phase Complete
  □ Milestones defined
  □ MVP scope identified
  □ Risk mitigation plans documented
  □ Rollback strategy defined
  □ User stories prioritized (P0-P3)
```

---

## 🎯 Quick Reference: DDD Tactics

### Aggregate Rules (Non-Negotiable)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AGGREGATE DESIGN PRINCIPLES                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. TRANSACTION BOUNDARY                                                     │
│     ┌─────────────────┐                                                      │
│     │   AGGREGATE     │  One transaction = One aggregate save               │
│     │  ┌───────────┐  │                                                      │
│     │  │  Root     │  │  Root Entity: Has global identity                  │
│     │  │  Entity   │  │                                                      │
│     │  └─────┬─────┘  │  Invariants enforced across entire boundary       │
│     │  ┌─────┴─────┐  │                                                      │
│     │  │ Entities  │  │  Child Entities: Local identity only             │
│     │  │  (1..*)   │  │                                                      │
│     │  ├───────────┤  │  Value Objects: Immutable, replace not modify       │
│     │  │ Value Obj │  │                                                      │
│     │  │  (0..*)   │  │                                                      │
│     │  └───────────┘  │                                                      │
│     └─────────────────┘                                                      │
│                                                                              │
│  2. REFERENCE RULE                                                           │
│     • Inside aggregate: Reference by object                                   │
│     • Outside aggregate: Reference by ID only                               │
│                                                                              │
│  3. DELETE RULE                                                              │
│     • Delete aggregate = Delete everything inside                           │
│     • Orphaned entities should not exist                                    │
│                                                                              │
│  4. SIZE RULE                                                                │
│     • Small aggregates: Better performance, less contention                 │
│     • Large aggregates: More consistency, more locking                      │
│     • "FANG Rule": Start small, expand only when data proves need          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Domain Event Best Practices

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  DOMAIN EVENT GUIDELINES                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  NAMING: [Entity][Action]Occurred / [Entity][Action]Completed             │
│                                                                              │
│  • OrderPlaced                                                              │
│  • PaymentReceived                                                          │
│  • InventoryReserved                                                        │
│  • ShipmentDispatched                                                       │
│                                                                              │
│  CONTENT:                                                                   │
│  • Event ID (UUID)                                                          │
│  • Aggregate ID                                                             │
│  • Timestamp (UTC)                                                          │
│  • Version/Schema version                                                   │
│  • Payload (minimal, event-specific data)                                   │
│  • Correlation ID (for distributed tracing)                                 │
│                                                                              │
│  FANG PRINCIPLES:                                                           │
│  • Events are facts - immutable and append-only                             │
│  • Event schema evolution: Additive only (never delete fields)              │
│  • Include just enough data - consumers shouldn't query for context         │
│  • Idempotency keys for all handlers                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Phase 6: Execution Framework

### Sprint 0: Foundation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SPRINT 0: ARCHITECTURE FOUNDATION (Weeks 1-2)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Week 1: Setup & Discovery                                                   │
│  ├── Day 1-2: Stakeholder interviews (collect 3+ scopes/pains/tech)        │
│  ├── Day 3-4: Event Storming workshop                                       │
│  ├── Day 5: Domain analysis documentation                                   │
│  └── Deliverable: User Story YAML files (spec-ddd/feat-*.yml)               │
│                                                                              │
│  Week 2: Design & Planning                                                   │
│  ├── Day 1-2: Bounded context identification                              │
│  ├── Day 3: Context mapping & integration design                            │
│  ├── Day 4: ADR writing (Architecture Decision Records)                     │
│  └── Day 5: Technical setup (CI/CD, repo structure, base libs)            │
│                                                                              │
│  Deliverables:                                                               │
│  □ Discovery document (ES/EN analysis complete)                            │
│  □ User Story YAML files in spec-ddd/                                       │
│  □ Event storming board                                                    │
│  □ Context map diagram                                                       │
│  □ ADR documents (minimum 3)                                               │
│  □ Repository structure with working CI/CD                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Development Sprints

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PER-SPRINT DELIVERABLES                                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Each sprint delivers ONE complete vertical slice:                          │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐     │
│  │  VERTICAL SLICE PATTERN                                             │     │
│  │                                                                     │     │
│  │  Feature: [User Story from spec-ddd/]                               │     │
│  │                                                                     │     │
│  │  UI/CLI ──► Controller ──► Use Case ──► Domain ──► Repository    │     │
│  │     │         │           │           │           │                 │     │
│  │     │         │           │           │           ▼                 │     │
│  │     │         │           │           │        Database             │     │
│  │     │         │           │           │                             │     │
│  │     │         │           │           ▼                             │     │
│  │     │         │           │      Domain Events ──► Event Bus       │     │
│  │     │         │           │                             │          │     │
│  │     │         │           │                             ▼          │     │
│  │     │         │           │                        Event Handlers   │     │
│  │     │         │           │                             │          │     │
│  │     │         │           ▼                             ▼          │     │
│  │     │         ▼      Integration                    External      │     │
│  │     ▼    Tests/Contract    Tests                    Systems         │     │
│  │  E2E Tests                                                     ◄────┘     │
│  │                                                                     │     │
│  └─────────────────────────────────────────────────────────────────────┘     │
│                                                                              │
│  Definition of Done:                                                         │
│  □ User Story completed per YAML specification                               │
│  □ Acceptance criteria verified                                              │
│  □ Unit tests (domain logic) - 80%+ coverage                               │
│  □ Integration tests (repositories, external services)                       │
│  □ API contract tests (OpenAPI/gRPC spec)                                    │
│  □ Observability (metrics, logs, traces)                                    │
│  □ Documentation updated                                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Phase 7: Observability & Monitoring (FANG Grade)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  THE THREE PILLARS OF OBSERVABILITY                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. METRICS (The "What")                                                    │
│  ─────────────────────                                                       │
│                                                                              │
│  Business Metrics:                                                           │
│  • Orders per minute                                                         │
│  • Revenue per hour                                                          │
│  • Conversion rate                                                           │
│                                                                              │
│  Domain Metrics:                                                             │
│  • Aggregate creation rate                                                   │
│  • Domain event frequency by type                                            │
│  • Command handling time                                                       │
│                                                                              │
│  Technical Metrics:                                                          │
│  • Request rate, latency (p50, p95, p99), error rate                         │
│  • DB connection pool utilization                                            │
│  • Queue depth                                                               │
│                                                                              │
│  2. LOGS (The "Why")                                                        │
│  ──────────────────                                                          │
│                                                                              │
│  Structured JSON logging with:                                               │
│  • trace_id (distributed request tracking)                                   │
│  • span_id (operation within request)                                        │
│  • aggregate_id (DDD-specific tracking)                                      │
│  • correlation_id (business process tracking)                                │
│  • story_id (links to spec-ddd/ user story)                                 │
│                                                                              │
│  Log Levels:                                                                 │
│  • ERROR: Aggregates in invalid state, invariant violations                  │
│  • WARN: Retryable failures, deprecated API usage                            │
│  • INFO: Domain events published, significant state changes                  │
│  • DEBUG: Command handling details, query execution                            │
│                                                                              │
│  3. TRACES (The "Where")                                                    │
│  ─────────────────────                                                       │
│                                                                              │
│  Distributed tracing across:                                                 │
│  • API Gateway → Controller → Use Case → Domain → Repository → DB            │
│  • Event Publisher → Message Bus → Event Handler → Downstream Actions        │
│                                                                              │
│  Critical Spans:                                                             │
│  • Aggregate load/save                                                       │
│  • Domain event processing                                                   │
│  • External service calls                                                    │
│  • User story execution (from spec-ddd/)                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎓 DDD Pattern Library

### Strategic Patterns

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  STRATEGIC PATTERNS QUICK REFERENCE                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PATTERN              │ USE WHEN                              │ EXAMPLE     │
│  ─────────────────────┼───────────────────────────────────────┼────────────│
│  BOUNDED CONTEXT      │ Clear linguistic boundaries exist     │ Catalog vs  │
│                       │                                       │ Inventory   │
│  ─────────────────────┼───────────────────────────────────────┼────────────│
│  CONTEXT MAP          │ Multiple contexts interact            │ Sales ↔     │
│                       │                                       │ Shipping    │
│  ─────────────────────┼───────────────────────────────────────┼────────────│
│  SHARED KERNEL        │ Teams collaborate closely             │ Common      │
│                       │                                       │ types lib   │
│  ─────────────────────┼───────────────────────────────────────┼────────────│
│  CUSTOMER/SUPPLIER    │ Clear upstream/downstream             │ Pricing API │
│                       │                                       │ (upstream)  │
│  ─────────────────────┼───────────────────────────────────────┼────────────│
│  CONFORMIST           │ Can't influence upstream                │ Using       │
│                       │                                       │ external API│
│  ─────────────────────┼───────────────────────────────────────┼────────────│
│  ANTI-CORRUPTION      │ Legacy integration needed             │ Translating │
│  LAYER                │                                       │ old to new  │
│  ─────────────────────┼───────────────────────────────────────┼────────────│
│  OPEN HOST SERVICE    │ Providing standard protocol           │ Public API  │
│  ─────────────────────┼───────────────────────────────────────┼────────────│
│  PUBLISHED LANGUAGE   │ Sharing formalized model              │ Event       │
│                       │                                       │ schemas     │
│  ─────────────────────┼───────────────────────────────────────┼────────────│
│  SEPARATE WAYS        │ Integration cost > Duplication cost   │ Custom auth │
│                       │                                       │ per service │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Tactical Patterns

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  TACTICAL PATTERNS QUICK REFERENCE                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ENTITY                                                                 │
│  • Has identity that persists through state changes                          │
│  • Identity matters even if all attributes change                            │
│  • Example: User (same person even if name/email changes)                    │
│                                                                              │
│  VALUE OBJECT                                                             │
│  • Immutable, compared by all attributes                                       │
│  • No identity - create new instead of modifying                               │
│  • Example: Money(amount, currency), Address(street, city, zip)            │
│                                                                              │
│  AGGREGATE                                                                │
│  • Consistency boundary cluster                                                │
│  • Root entity controls all access to children                                 │
│  • Example: Order (root) containing OrderItems (children)                  │
│                                                                              │
│  DOMAIN EVENT                                                             │
│  • Something that happened in the domain                                       │
│  • Immutable record of past occurrence                                         │
│  • Example: OrderShipped, PaymentFailed                                      │
│                                                                              │
│  DOMAIN SERVICE                                                           │
│  • Business logic that doesn't fit in entity/value object                    │
│  • Stateless operations across multiple aggregates                           │
│  • Example: PricingCalculator, TransferService                               │
│                                                                              │
│  REPOSITORY                                                               │
│  • Abstracts persistence - domain talks to interface                         │
│  • Returns fully-hydrated aggregates                                          │
│  • Example: OrderRepository.save(order), OrderRepository.findById(id)       │
│                                                                              │
│  FACTORY                                                                  │
│  • Encapsulates complex aggregate creation                                   │
│  • Ensures invariants satisfied from birth                                    │
│  • Example: OrderFactory.createForCustomer(customerId, items)               │
│                                                                              │
│  DOMAIN EVENT PUBLISHER                                                   │
│  • Mechanism to publish events from aggregates                               │
│  • Usually injected or provided via Unit of Work                              │
│  • Example: aggregate.publishEvent(new OrderPlaced(...))                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 The FANG Feedback Loop

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CONTINUOUS DOMAIN REFINEMENT                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │   EVENT     │───►│  ANALYZE    │───►│   UPDATE    │───►│   DEPLOY    │  │
│  │  STORMING   │    │   METRICS   │    │   MODEL     │    │   CHANGE    │  │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘  │
│        ▲                                                       │            │
│        │                                                       │            │
│        └───────────────────────────────────────────────────────┘            │
│                        OBSERVE & LEARN                                       │
│                                                                              │
│  Quarterly Domain Review:                                                    │
│  □ Ubiquitous language still accurate?                                      │
│  □ Aggregates handling load appropriately?                                  │
│  □ Event schema evolution tracked?                                          │
│  □ New bounded contexts emerging?                                           │
│  □ User stories in spec-ddd/ still relevant?                                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📚 References

### Books (FANG-Recommended)
- **"Domain-Driven Design"** by Eric Evans (The Blue Book) - Foundation
- **"Implementing Domain-Driven Design"** by Vaughn Vernon (The Red Book) - Practical
- **"Domain-Driven Design Distilled"** by Vaughn Vernon - Quick start
- **"Building Microservices"** by Sam Newman - Context boundaries
- **"Designing Data-Intensive Applications"** by Martin Kleppmann - Technical depth

### Online Resources
- DDD Europe Conference Talks (YouTube)
- Virtual DDD Community (virtualddd.com)
- Event Modeling (eventmodeling.org)
- Martin Fowler's bliki (martinfowler.com)

### Tools
- **Event Storming**: Miro, Mural, physical sticky notes
- **Context Mapping**: Visual Paradigm, diagrams.net
- **Code Modeling**: JetBrains DDD plugin, ArchUnit
- **Documentation**: Arc42, C4 Model
- **User Stories**: YAML specs in spec-ddd/

---

## 🎯 Summary: The skill-spec-ddd Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  MINIMUM VIABLE PROCESS (Start Here)                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. REQUIREMENTS (Non-negotiable minimums)                                   │
│     □ List 3+ scopes                                                        │
│     □ List 3+ technical scopes                                              │
│     □ List 3+ pain points                                                   │
│     □ Create spec-ddd/feat-*.yml files                                       │
│                                                                              │
│  2. ANALYSIS (Dual language)                                                │
│     □ Analyze each item in ES                                               │
│     □ Analyze each item in EN                                               │
│     □ Document complexity, risks, and solutions                             │
│     □ Update user story YAML files                                           │
│                                                                              │
│  3. DECOMPOSITION (Stack Engineer mindset)                                  │
│     □ Map business capabilities → domains                                   │
│     □ Identify bounded contexts                                             │
│     □ Design aggregates and domain events                                   │
│     □ Draw context map with integration patterns                            │
│     □ Map user stories to aggregates                                        │
│                                                                              │
│  4. DECISIONS (ADR discipline)                                            │
│     □ Write ADR for architecture style                                      │
│     □ Write ADR for persistence strategy                                    │
│     □ Write ADR for communication patterns                                  │
│                                                                              │
│  5. IMPLEMENTATION (FANG execution)                                         │
│     □ Sprint 0: Foundation + User Story YAMLs                               │
│     □ Vertical slices per sprint (one user story at a time)                │
│     □ Observability from day one                                            │
│     □ Quarterly domain reviews                                              │
│                                                                              │
│  SUCCESS CRITERIA:                                                          │
│  ✓ System handles projected load (plan for 10x)                           │
│  ✓ New developers understand domain in < 1 week                             │
│  ✓ Changes deploy without fear                                              │
│  ✓ Domain language matches business language                                │
│  ✓ Can answer "why" for any architectural choice                            │
│  ✓ User stories traceable from spec-ddd/ to code                              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

**Remember the FANG Principles:**
1. **Start simple, evolve based on data** - Don't over-engineer prematurely
2. **Clear ownership, clear interfaces** - Every context has an owner
3. **Measure everything** - If you can't observe it, you can't improve it
4. **Document decisions** - Context is as important as code
5. **Domain language is sacred** - Ubiquitous language prevents bugs
6. **User stories as code** - YAML specs living alongside the domain

**Act like your system will need to serve 100 million users tomorrow.**
