# Todo Templates

Pre-written `todo_desirable` items organized by layer and priority.
The agent uses these as inspiration when building the final report.

## Domain Layer

### P0 (Critical - Do First)
- Remove all external imports (ORM, HTTP, frameworks) from Domain files
- Move repository interfaces from Infrastructure into Domain
- Move business rules currently in Application/Controllers into Domain Entities or Domain Services
- Ensure every aggregate root has a corresponding repository interface (port) in Domain

### P1 (Important - Next)
- Add behavior methods to entities to avoid anemic domain model
- Extract value objects for primitive concepts (Email, Money, UUID)
- Add domain event publishing for state changes that external systems care about
- Validate that all invariants are enforced inside Domain (not in DB triggers or controllers)

### P2 (Nice to Have)
- Add LAYER header comments to all Domain files
- Standardize entity naming to `*.entity.{ext}`
- Document domain boundaries with ubiquitous language glossary

---

## Application Layer

### P0 (Critical - Do First)
- Ensure use cases only orchestrate; move business rules to Domain
- Rename files to follow `*.use-case.{ext}` or `*.command.{ext}` / `*.query.{ext}`
- Ensure DTOs are flat (no nested ORM models or framework objects)
- Every use case should have exactly one public method (e.g., `execute()`)

### P1 (Important - Next)
- Split god use cases (>200 lines or >5 constructor dependencies) into smaller ones
- Add application-specific ports for external services (email, SMS, payment)
- Ensure transaction boundaries are managed in Application (not Infrastructure)
- Standardize DTO naming: `*.request.dto.{ext}`, `*.response.dto.{ext}`

### P2 (Nice to Have)
- Add LAYER header comments to all Application files
- Use constructor injection for all dependencies
- Document each use case with expected input/output examples

---

## UseCases Layer (if separate from Application)

### P0
- Ensure UseCases only import Domain and/or Application
- Move orchestration-only logic to Application; keep UseCases focused on a single user goal

### P1
- Standardize naming: `*.interactor.{ext}` or `*.use-case.{ext}`
- Group use cases by feature or aggregate root

---

## Infrastructure Layer

### P0 (Critical - Do First)
- Move all repository implementations into Infrastructure
- Ensure Infrastructure implements ports defined in Domain/Application (not the other way around)
- Remove any business logic from Infrastructure services
- Ensure Infrastructure does NOT import from Interface/Presentation

### P1 (Important - Next)
- Add mapper/converter between DB models and Domain entities
- Separate framework-specific code (Express, NestJS, Prisma) from generic adapter logic
- Standardize naming: `*.repository.{ext}`, `*.service.{ext}`, `*.adapter.{ext}`

### P2 (Nice to Have)
- Add LAYER header comments to all Infrastructure files
- Abstract external API clients behind interfaces defined in Application
- Add resilience patterns (retries, circuit breakers) for external calls

---

## Interface Layer

### P0 (Critical - Do First)
- Refactor controllers to only depend on Application use cases (no direct Domain or Infra)
- Remove all business logic from controllers, routes, and middleware
- Never expose Domain entities directly in HTTP responses (map to DTOs)

### P1 (Important - Next)
- Standardize controller naming: `*.controller.{ext}` or `*.handler.{ext}`
- Move input validation to dedicated validators or middleware (not controllers)
- Ensure HTTP status codes and headers are handled in Interface, not leaked to Application

### P2 (Nice to Have)
- Add LAYER header comments to all Interface files
- Add OpenAPI/ Swagger documentation generation
- Standardize error response format

---

## Cross-Cutting (All Layers)

### P0
- Fix circular dependencies between layers
- Enforce single direction: Domain <- Application <- Infrastructure / Interface

### P1
- Standardize naming conventions across all layers (kebab-case preferred)
- Add LAYER header comments to every file
- Set up a composition root / dependency injection container (manual, no complex framework)

### P2
- Add architecture tests (e.g., `dependency-cruiser`, `archunit`, custom scripts) to CI
- Document the layer boundaries and dependency rules in README
- Create examples of correct file placement for new developers
