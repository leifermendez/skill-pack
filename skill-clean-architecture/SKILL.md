---
name: skill-clean-architecture
description: >-
  Expert in Clean Architecture + Domain-Driven Design (DDD).
  Enforces strict separation of layers: Domain, Application, Infrastructure, Interface.
  No over-engineering - only essential patterns.
  Every file must start with a layer documentation comment.
compatibility: Framework agnostic. Works with Node.js, Python, Java, PHP, etc.
metadata:
  author: leifermendez
  version: "2.0"
  tags: "clean-architecture, ddd, solid, dependency-inversion, layered-architecture"
---

## Core Philosophy: Basic Pillars, No Over-Engineering

This skill enforces **only the essential 4 layers** of Clean Architecture. No complex abstractions, no unnecessary patterns, no premature optimization.

### The 4 Basic Pillars (Manténlo Simple)

1. **Domain** - Entidades y reglas de negocio puras (POJOs/POCOs)
2. **Application** - Casos de uso simples (orquestación)
3. **Infrastructure** - Implementaciones concretas (DB, APIs externas)
4. **Interface** - Controllers HTTP (manejo de requests/responses)

### What We DON'T Want (Over-Engineering)

❌ **Abstract factories** para todo  
❌ **Event buses** complejos si no hay eventos  
❌ **CQRS** sin necesidad de escalabilidad  
❌ **Unit of Work** si solo hay un repositorio  
❌ **Mappers** innecesarios (usa objetos planos)  
❌ **Decorators** de clases solo por "extensibilidad"  
❌ **Services de dominio** si la lógica cabe en la entidad  

### What We DO Want (Keep It Simple)

✅ **Entidades simples** con validación básica  
✅ **Interfaces de repositorio** solo con métodos necesarios  
✅ **Casos de uso** que orquestan (no lógica de negocio)  
✅ **Inyección manual** (sin frameworks de DI complejos)  
✅ **DTOs planos** (clases o interfaces simples)  
✅ **Un archivo por responsabilidad** (nada de mega-clases)

---

## Project Discovery

When analyzing a project, always look for source code in these common folders:

**Priority search locations:**
1. `src/` - Standard source folder (Node.js, TypeScript, Java)
2. `app/` - Common in Next.js, Rails, Django projects
3. `lib/` - Library code (Elixir, Ruby, some Node.js)
4. `codebase/` - Legacy or enterprise projects
5. `packages/` - Monorepo structure
6. `src/main/` - Java/Maven standard
7. `src/app/` - Angular/NestJS default

**If no standard folder found:**
- Look for `.ts`, `.js`, `.py`, `.java` files in root
- Check `package.json` for "main" entry point
- Follow imports from entry files

Always identify the main source directory before analyzing architecture.

---

## Improvement Roadmap (Risk/Impact Matrix)

When proposing architectural improvements, always prioritize by **LOW RISK + FAST IMPACT** first.

### The Improvement Matrix

```
                    IMPACT
               Low        High
           ┌──────────┬──────────┐
    Low    │ Fill-Ins │ QUICK    │
  RISK     │ (avoid)  │ WINS ⭐  │
           ├──────────┼──────────┤
    High   │ Hard     │ Major    │
           │ Changes  │ Projects │
           └──────────┴──────────┘
```

### Priority Order (Always follow this)

#### 1. QUICK WINS ⭐ (Do First)
**Low Risk + High Impact**
- Add LAYER headers to existing files
- Extract interfaces for repositories (no behavior change)
- Move DTOs to Application layer
- Simple dependency inversion (constructor injection)
- **Effort:** Hours to 1-2 days
- **Risk:** Minimal (additive, non-breaking)

#### 2. MAJOR PROJECTS (Plan Carefully)
**High Risk + High Impact**
- Migrate from ActiveRecord to Repository pattern
- Extract Domain layer from anemic models
- Split monolithic use cases
- Change ORM or database technology
- **Effort:** Weeks
- **Risk:** High (requires testing, gradual migration)

#### 3. FILL-INS (Avoid or Do Last)
**Low Risk + Low Impact**
- Rename variables for "consistency"
- Reformat code (prettier already does this)
- Move files between folders without semantic change
- Add comments to obvious code
- **Effort:** Low
- **Risk:** None
- **Value:** Minimal - skip unless blocking other work

#### 4. HARD CHANGES (Avoid or Defer)
**High Risk + Low Impact**
- Rewrite working code "just because"
- Change naming conventions globally
- Refactor stable legacy code with no bugs
- **Effort:** High
- **Risk:** High
- **Value:** Low - avoid unless necessary

### Migration Strategy Example

**Week 1-2: Quick Wins**
```
✅ Add LAYER comments to all files
✅ Create repository interfaces (implement later)
✅ Move business logic from controllers to services
```

**Week 3-4: Setup Infrastructure**
```
✅ Implement one repository with tests
✅ Add dependency injection container
✅ Migrate one feature end-to-end
```

**Month 2+: Gradual Migration**
```
🔄 Migrate remaining features one by one
🔄 Keep old code working during transition
🔄 Test after each migration
```

### Rule of Thumb

> **"Never break working code to 'improve' architecture. Evolution, not revolution."**

- Always leave the codebase better than you found it
- Make additive changes first (new layer alongside old)
- Migrate incrementally (one use case at a time)
- Tests are mandatory before structural changes

---

## References

Based on principles from:
- **The Clean Architecture** by Robert C. Martin (Uncle Bob)
- **Domain-Driven Design** by Eric Evans  
- **Hexagonal Architecture** by Alistair Cockburn
- **SOLID Principles**

Detailed guides and examples in the `references/` folder:

### Patterns (Cómo hacerlo bien)
- [`references/patterns/repository-pattern.md`](references/patterns/repository-pattern.md) - Repository Pattern con interfaz en Domain
- [`references/patterns/dependency-injection-simple.md`](references/patterns/dependency-injection-simple.md) - Inyección manual sin frameworks
- [`references/patterns/use-case-pattern.md`](references/patterns/use-case-pattern.md) - Estructura de Use Cases

### Anti-Patterns (Qué NO hacer)
- [`references/anti-patterns/anemic-domain-model.md`](references/anti-patterns/anemic-domain-model.md) - Entidades sin comportamiento
- [`references/anti-patterns/infrastructure-in-domain.md`](references/anti-patterns/infrastructure-in-domain.md) - Frameworks en Domain
- [`references/anti-patterns/god-use-case.md`](references/anti-patterns/god-use-case.md) - Use cases gigantes
- [`references/anti-patterns/leaky-abstraction.md`](references/anti-patterns/leaky-abstraction.md) - Abstracciones que filtran

### Code Style (Buenas prácticas)
- [`references/code-style/early-return.md`](references/code-style/early-return.md) - Guard clauses, código plano
- [`references/code-style/type-safe.md`](references/code-style/type-safe.md) - TypeScript strict, no any, branded types
- [`references/code-style/jsdoc-tsdoc.md`](references/code-style/jsdoc-tsdoc.md) - Documentación con JSDoc/TSDoc

### Examples (Ejemplos prácticos)
- [`references/examples/`](references/examples/) - Ejemplos completos de flujos

---

## Layer Documentation Rule

**MANDATORY**: Every file MUST start with a comment indicating its layer:

```typescript
/**
 * LAYER: Domain
 * Contains: Entities, Value Objects, Domain Services, Repository Interfaces
 * Rules: No external dependencies. Pure business logic only.
 */
```

Available layer tags: `Domain` | `Application` | `Infrastructure` | `Interface`

---

## Architecture Layers (Inside-Out)

### 1. DOMAIN (Center - Most Protected)

**Contains:**
- Entities (Aggregate Roots, Entities)
- Value Objects (immutable, validated)
- Domain Services (complex business logic spanning multiple entities)
- Repository Interfaces (ports - only definitions)
- Domain Events

**Rules:**
- ZERO external dependencies (no frameworks, no DB, no HTTP)
- No imports from outer layers (Application, Infrastructure, Interface)
- Pure TypeScript/JavaScript/any language - only language primitives
- Business invariants enforced here
- Immutability preferred for Value Objects

**Example Structure:**
```
src/domain/
├── entities/
│   └── user.entity.ts
├── value-objects/
│   └── email.vo.ts
├── repositories/
│   └── user.repository.interface.ts
└── services/
    └── user-domain.service.ts
```

---

### 2. APPLICATION (Use Cases / Orchestration)

**Contains:**
- Use Cases (application services)
- DTOs (Data Transfer Objects - input/output)
- Ports (interfaces for external services needed by use cases)
- Application Services

**Rules:**
- Depends ONLY on Domain layer
- No frameworks (no Express, no Fastify, no DB drivers directly)
- Orchestrates domain entities to fulfill use cases
- Defines "ports" (interfaces) for infrastructure to implement
- Transaction management lives here
- NO business logic - only coordination logic

**Example Structure:**
```
src/application/
├── use-cases/
│   ├── create-user.use-case.ts
│   └── get-user.use-case.ts
├── dtos/
│   ├── create-user.dto.ts
│   └── user-response.dto.ts
└── ports/
    ├── id-generator.port.ts
    └── email-service.port.ts
```

---

### 3. INFRASTRUCTURE (External Concerns)

**Contains:**
- Repository Implementations (database access)
- External Service Clients (HTTP, email, SMS, payment gateways)
- Framework Adapters (Express, Fastify, NestJS adapters)
- Database Models/ORM entities (different from Domain entities!)
- Configuration and environment handling

**Rules:**
- Depends on Domain AND Application layers
- Implements interfaces (ports) defined in inner layers
- Can use ANY framework, library, or external service
- Converts between DB models and Domain entities
- Handles technical details (caching, retries, connection pools)

**Example Structure:**
```
src/infrastructure/
├── database/
│   ├── prisma-user.repository.ts
│   └── models/
│       └── user.model.ts
├── services/
│   ├── sendgrid-email.service.ts
│   └── uuid-generator.service.ts
└── config/
    └── database.config.ts
```

---

### 4. INTERFACE (Presentation / Controllers)

**Contains:**
- Controllers (HTTP handlers)
- Routes definitions
- Middlewares (auth, validation, logging)
- Request/Response mappers
- Input validation (DTO validation)

**Rules:**
- Depends on Application layer (use cases)
- NO direct access to Domain or Infrastructure
- Handles HTTP specifics (status codes, headers, JSON parsing)
- Validates and sanitizes input
- Converts HTTP requests to Application DTOs
- Returns HTTP responses (never expose domain entities directly)

**Example Structure:**
```
src/interface/
├── http/
│   ├── controllers/
│   │   └── user.controller.ts
│   ├── routes/
│   │   └── user.routes.ts
│   ├── middlewares/
│   │   └── auth.middleware.ts
│   └── validators/
│       └── user.validator.ts
└── cli/ (optional)
    └── commands/
```

---

## Dependency Rule (The Golden Rule)

```
┌─────────────────────────────────┐
│         INTERFACE               │  ◄── HTTP, CLI, GUI
│         (Frameworks)            │
├─────────────────────────────────┤
│         INFRASTRUCTURE          │  ◄── DB, External APIs, Services
│         (Adapters)              │
├─────────────────────────────────┤
│         APPLICATION             │  ◄── Use Cases, Orchestration
│         (Business Flow)         │
├─────────────────────────────────┤
│           DOMAIN                │  ◄── Business Rules, Entities
│         (Core/Business)         │
└─────────────────────────────────┘
```

**Dependencies ALWAYS point INWARD.**
- Domain knows NOTHING about other layers.
- Application knows about Domain only.
- Infrastructure knows about Domain and Application.
- Interface knows about Application only.

---

## File Header Templates

### Domain Layer
```typescript
/**
 * LAYER: Domain
 * Contains: Entities, Value Objects, Domain Services
 * Rules: No external dependencies. Pure business logic.
 */
```

### Application Layer
```typescript
/**
 * LAYER: Application
 * Contains: Use Cases, DTOs, Ports
 * Rules: Orchestrates domain. No frameworks. Defines ports.
 */
```

### Infrastructure Layer
```typescript
/**
 * LAYER: Infrastructure
 * Contains: Repository implementations, external services
 * Rules: Implements ports from Application. Can use any framework.
 */
```

### Interface Layer
```typescript
/**
 * LAYER: Interface
 * Contains: Controllers, Routes, Middlewares
 * Rules: Handles HTTP. Calls use cases only. No direct domain/infrastructure access.
 */
```

---

## Minimal Example (No Over-Engineering)

### Domain
```typescript
// src/domain/entities/user.ts
/**
 * LAYER: Domain
 * Contains: User Entity
 * Rules: No external dependencies.
 */
export class User {
  constructor(
    public readonly id: string,
    public readonly email: string,
    public readonly name: string
  ) {
    if (!email.includes('@')) throw new Error('Invalid email');
  }
}

// src/domain/repositories/user.repo.interface.ts
/**
 * LAYER: Domain
 * Contains: Repository Interface (Port)
 * Rules: Only definition, no implementation.
 */
export interface IUserRepository {
  save(user: User): Promise<void>;
  findById(id: string): Promise<User | null>;
}
```

### Application
```typescript
// src/application/use-cases/create-user.ts
/**
 * LAYER: Application
 * Contains: Create User Use Case
 * Rules: Orchestrates domain. Depends only on domain.
 */
export class CreateUserUseCase {
  constructor(
    private readonly userRepo: IUserRepository,
    private readonly idGenerator: IIdGenerator
  ) {}

  async execute(input: CreateUserDTO): Promise<UserResponseDTO> {
    const user = new User(
      this.idGenerator.generate(),
      input.email,
      input.name
    );
    await this.userRepo.save(user);
    return { id: user.id, email: user.email, name: user.name };
  }
}
```

### Infrastructure
```typescript
// src/infrastructure/database/prisma-user.repo.ts
/**
 * LAYER: Infrastructure
 * Contains: Prisma User Repository Implementation
 * Rules: Implements domain interface. Can use Prisma.
 */
export class PrismaUserRepository implements IUserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async save(user: User): Promise<void> {
    await this.prisma.user.create({
      data: { id: user.id, email: user.email, name: user.name }
    });
  }
  // ...
}
```

### Interface
```typescript
// src/interface/http/controllers/user.controller.ts
/**
 * LAYER: Interface
 * Contains: User HTTP Controller
 * Rules: Handles HTTP only. Calls use cases. No direct DB access.
 */
export class UserController {
  constructor(private readonly createUserUseCase: CreateUserUseCase) {}

  async create(req: Request, res: Response) {
    const dto = req.body;
    const result = await this.createUserUseCase.execute(dto);
    res.status(201).json(result);
  }
}
```

---

## Anti-Patterns to Avoid

❌ **Domain entity importing an ORM decorator**  
❌ **Use case calling a database directly** (use repository interface)  
❌ **Controller calling repository directly** (must go through use case)  
❌ **Business logic in controllers**  
❌ **Infrastructure details in domain** (dates, UUID generation, etc.)  
❌ **Circular dependencies between layers**

---

## Dependency Injection (Simple)

Use a simple composition root (DI container or manual wiring):

```typescript
// src/composition.ts
const prisma = new PrismaClient();
const idGenerator = new UuidGenerator();
const userRepo = new PrismaUserRepository(prisma);
const createUserUseCase = new CreateUserUseCase(userRepo, idGenerator);
const userController = new UserController(createUserUseCase);
// Routes receive controller
```

---

## Summary Checklist

- [ ] Every file starts with LAYER comment
- [ ] Domain has zero external dependencies
- [ ] Application only imports from Domain
- [ ] Infrastructure implements Application ports
- [ ] Interface only imports from Application
- [ ] Dependencies point inward only
- [ ] No business logic in controllers
- [ ] No ORM entities in Domain
- [ ] Repository interfaces in Domain, implementations in Infrastructure
- [ ] Use cases orchestrate, don't contain business rules
