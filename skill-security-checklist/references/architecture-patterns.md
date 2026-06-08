# Architecture Patterns Reference

## Pattern Detection Guide

This reference helps identify common software architecture patterns from codebase structure.

### Domain-Driven Design (DDD)

**Indicators:**
- Folders: `domain/`, `aggregates/`, `entities/`, `value-objects/`, `repositories/`, `services/`, `events/`
- Files: `*Aggregate*`, `*Entity*`, `*ValueObject*`, `*Repository*`, `*DomainEvent*`, `*Service*`
- Imports: domain layer imports only other domain; infrastructure imports domain

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Business alignment | Code mirrors business concepts and language |
| Maintainability | Clear boundaries make changes localized |
| Testability | Domain logic is isolated from infrastructure |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Learning curve | Requires understanding of DDD concepts |
| Initial complexity | More boilerplate than simple CRUD |
| Over-engineering | Risk of applying DDD to simple domains |

### Model-View-Controller (MVC)

**Indicators:**
- Folders: `models/`, `views/`, `controllers/`, `routes/`, `templates/`
- Files: `*Controller*`, `*Model*`, `*View*`, `*Route*`
- Frameworks: Express.js, Django, Rails, Laravel, ASP.NET MVC

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Familiarity | Most developers know MVC |
| Separation | UI logic separated from business logic |
| Rapid development | Many frameworks support MVC out-of-the-box |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Fat controllers | Business logic often leaks into controllers |
| Tight coupling | Models often tied to database schema |
| Testing difficulty | Controllers with many dependencies hard to test |

### Hexagonal Architecture (Ports & Adapters)

**Indicators:**
- Folders: `domain/`, `application/`, `infrastructure/`, `adapters/`, `ports/`
- Files: `*Port*`, `*Adapter*`, `*UseCase*`, `*ApplicationService*`
- Dependency direction: Infrastructure -> Application -> Domain

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Testability | Easy to mock adapters and test core logic |
| Flexibility | Swap infrastructure without touching domain |
| Clean boundaries | Dependencies point inward only |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Verbosity | More interfaces and abstractions |
| Mapping overhead | DTOs and mappers between layers |
| Team buy-in | Requires discipline to maintain boundaries |

### Clean Architecture

**Indicators:**
- Folders: `entities/`, `usecases/`, `interface-adapters/`, `frameworks/`
- Dependency rule: No inner layer knows about outer layers
- Files: `*Entity*`, `*UseCase*`, `*Presenter*`, `*Controller*`

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Independence | Framework-independent business logic |
| Testability | Pure domain logic with no external dependencies |
| Scalability | Easy to add new interfaces without touching core |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Complexity | Many layers and abstractions for small projects |
| Boilerplate | Mappers, DTOs, and interfaces everywhere |
| Performance | Potential overhead from indirection |

### Microservices

**Indicators:**
- Multiple `package.json` / `go.mod` / `pom.xml` files in subdirectories
- Service directories: `services/`, `apps/`, `workers/`, `api/`
- Communication: HTTP/gRPC, message queues, event bus
- Infrastructure: Docker per service, Kubernetes manifests

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Scalability | Scale services independently |
| Team autonomy | Teams own services end-to-end |
| Technology diversity | Use best language/tool per service |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Operational complexity | Monitoring, logging, tracing across services |
| Network overhead | Latency and failure modes increase |
| Data consistency | Distributed transactions challenging |

### Monolith

**Indicators:**
- Single build artifact
- One main entry point
- Shared database
- No service boundaries

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Simplicity | Single deploy, single codebase |
| Debugging | Easy to trace through the whole system |
| Performance | No network calls between components |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Scalability | Must scale entire app, not just hot parts |
| Coupling | Changes in one area can affect others |
| Deployment | Risky to deploy large codebase |

### Serverless

**Indicators:**
- `serverless.yml`, `template.yaml` (SAM), `functions/`, `handlers/`
- Cloud provider config: AWS Lambda, Azure Functions, Google Cloud Functions
- Event-driven: triggers, schedules, queues

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Cost | Pay per invocation, no idle servers |
| Scaling | Automatic scaling by cloud provider |
| Focus | Concentrate on business logic, not infrastructure |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Cold starts | Latency for infrequently used functions |
| Vendor lock-in | Tight coupling to cloud provider |
| Debugging | Hard to test and debug locally |

### Event-Driven Architecture

**Indicators:**
- `events/`, `handlers/`, `listeners/`, `subscribers/`, `producers/`, `consumers/`
- Message broker: Kafka, RabbitMQ, SQS, EventBridge
- Event schemas: `*Event*`, `*Command*`, `*Message*`

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Decoupling | Services communicate via events, not direct calls |
| Scalability | Scale producers and consumers independently |
| Resilience | Events can be replayed and retried |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Complexity | Eventual consistency, debugging, tracing |
| Schema evolution | Managing event schema changes |
| Ordering | Event ordering and deduplication challenges |

### CRUD / Transaction Script

**Indicators:**
- Direct database operations in controllers/handlers
- No domain layer, no services
- Simple forms and tables
- Framework scaffolding heavily used

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Speed | Fast to build simple applications |
| Simplicity | Minimal abstractions, easy to understand |
| Suitable | Perfect for admin panels, simple data entry |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Maintainability | Business logic scattered across controllers |
| Testing | Hard to unit test without domain layer |
| Growth | Does not scale with business complexity |

## Confidence Scoring

| Level | Criteria |
|-------|----------|
| **High** | Multiple indicators match, clear folder structure, consistent naming |
| **Medium** | Some indicators match, mixed patterns, legacy code |
| **Low** | Few indicators, ad-hoc structure, inconsistent |

## Anti-Patterns

| Anti-Pattern | Description | Risk |
|--------------|-------------|------|
| **Big Ball of Mud** | No discernible architecture | Critical |
| **Anemic Domain Model** | Entities with no behavior, all logic in services | High |
| **God Object** | Single class/file knows too much | High |
| **Spaghetti Code** | Tangled dependencies, no layers | High |
| **Golden Hammer** | Uses same pattern for everything | Medium |
| **Not Invented Here** | Rejects standard solutions | Medium |
