# Layer Discovery Patterns

This document catalogs how to detect Clean Architecture / DDD layers across different languages and frameworks.

---

## Universal Conventions

### Core layer folders (case-insensitive match)

| Canonical Name | Common Variants |
|---|---|
| **Domain** | `domain`, `domains`, `core`, `entities`, `entity`, `model`, `models` |
| **Application** | `application`, `applications`, `services`, `service`, `ports` |
| **UseCases** | `usecases`, `use-cases`, `use_cases`, `uc`, `interactors`, `features`, `feature` |
| **Infrastructure** | `infrastructure`, `infra`, `adapter`, `adapters`, `persistence`, `db`, `database`, `data`, `external` |
| **Interface** | `interface`, `interfaces`, `presentation`, `presenter`, `controller`, `controllers`, `api`, `http`, `rest`, `web`, `ui`, `cli`, `view`, `views`, `route`, `routes`, `handler`, `handlers`, `middleware`, `middlewares`, `interceptor`, `interceptors`, `guard`, `guards` |

### Ambiguous folder resolution

#### `app/` folder
- **Next.js / Nuxt / SvelteKit**: Usually `Interface` (contains routes, pages, API handlers).
- **NestJS / Adonis / Laravel**: Could be `Application` if it contains services and use-cases subfolders.
- **Ruby on Rails / Django**: Usually `Interface` + business logic mixed in.
- **Resolution rule**: Check for subfolders.
  - If it contains `domain/`, `use-cases/`, `dtos/` → treat as **Application**.
  - If it contains `routes/`, `pages/`, `controllers/`, `api/` → treat as **Interface**.

#### `services/` folder
- Inside `src/application/services/` → **Application**.
- Inside `src/domain/services/` → **Domain**.
- Inside `src/infrastructure/services/` → **Infrastructure**.
- Alone at `src/services/` → ambiguous; inspect imports to decide.

#### `lib/` or `utils/` folder
- Often contains cross-cutting helpers.
- If imported by Domain → must be pure functions only (zero external deps).
- If imported by Interface → can contain framework helpers.
- Flag for agent review if it mixes concerns.

---

## Language-Specific Conventions

### TypeScript / JavaScript (Node.js)

**Common structures:**
```
src/
  domain/           → Domain
  application/      → Application
    use-cases/      → UseCases (if nested)
    ports/          → Application ports
  infrastructure/   → Infrastructure
  interface/        → Interface
    http/           → Interface (HTTP controllers)
    cli/            → Interface (CLI handlers)
```

**Framework variants:**
- **NestJS**: `src/modules/` often mixes layers. Look for `@Entity()`, `@Controller()`, `@Injectable()` decorators to classify.
- **Express**: `src/routes/` = Interface, `src/services/` = ambiguous.
- **Next.js**: `app/` or `pages/` = Interface, `lib/` = ambiguous.

### Java (Spring / Jakarta EE)

**Common structures:**
```
src/main/java/com/example/
  domain/           → Domain
    model/          → Domain entities
    repository/     → Domain repository interfaces (ports)
    service/        → Domain services
  application/      → Application
    usecase/        → UseCases
    dto/            → DTOs
    port/           → Ports
  infrastructure/   → Infrastructure
    persistence/    → Repository implementations
    external/       → External service clients
    config/         → Configuration
  adapter/            → Interface (adapters)
    web/            → REST controllers
    cli/            → CLI adapters
```

**Maven / Gradle:**
- `src/main/java/` is the source root.
- Package names reveal layers (e.g., `com.example.domain.user`).

### Python (Django / FastAPI / Flask)

**Common structures:**
```
project/
  domain/           → Domain (rare in Django; common in FastAPI with DDD)
    entities/
    repositories/
  application/      → Application
    use_cases/
    dto/
  infrastructure/   → Infrastructure
    db/
    external/
  api/              → Interface (FastAPI routers)
  views/            → Interface (Django views)
  controllers/      → Interface (Flask routes)
```

**Django note:**
- Django apps (`blog/`, `shop/`) often mix Domain + Application + Interface.
- The agent must inspect `models.py` (Domain), `views.py` (Interface), `services.py` (Application).
- `models.py` importing `django.db.models` is expected (ORM), but flag if it imports `requests`, `celery`, etc.

### PHP (Laravel / Symfony)

**Common structures:**
```
app/
  Domain/           → Domain
    Entities/
    Repositories/
    Services/
  Application/      → Application
    UseCases/
    DTOs/
    Ports/
  Infrastructure/   → Infrastructure
    Eloquent/
    External/
    Persistence/
  Http/             → Interface (Laravel controllers)
  Console/          → Interface (Artisan commands)
```

**Laravel note:**
- `app/Models/` is often Eloquent ORM (Infrastructure concern masked as Domain).
- `app/Http/Controllers/` is Interface.
- `app/Services/` is ambiguous; inspect imports.

### Go

**Common structures:**
```
internal/
  domain/           → Domain
  application/      → Application
    usecase/
    dto/
  infrastructure/   → Infrastructure
    repository/
    service/
  delivery/         → Interface (HTTP handlers, gRPC handlers)
```

**Go note:**
- Go projects often use `internal/` to enforce package boundaries.
- `pkg/` may contain Domain or shared utilities.
- No generics before 1.18 means interfaces are manually defined.

### C# (.NET)

**Common structures:**
```
src/
  Domain/           → Domain
    Entities/
    Repositories/
    Services/
  Application/      → Application
    UseCases/
    DTOs/
    Ports/
  Infrastructure/   → Infrastructure
    Data/
    External/
  API/              → Interface (Controllers)
  Web/              → Interface (Razor pages, Blazor)
```

**.NET note:**
- `Entities/` with `DbContext` references = Infrastructure leak.
- `Controllers/` should only use MediatR / Application Services.
- `IRepository<T>` in Domain = correct; `EfRepository<T>` in Infrastructure = correct.

---

## Monorepo Considerations

### Structure
```
packages/
  api/              → Interface + Application
  core/             → Domain
  db/               → Infrastructure
  web/              → Interface
```

### Discovery strategy
1. Find all `packages/*/src/` directories.
2. Classify each package by its dominant layer.
3. Check cross-package imports in `package.json` (Node) or `go.mod` (Go) or `*.csproj` references (C#).
4. Validate that `core/` (Domain) is not imported by outer packages in a circular way.

---

## Legacy / Mixed Codebases

### Signs of mixed layers
- `src/models/` contains both ORM entities and business logic.
- `src/services/` contains 500-line classes with HTTP calls, DB queries, and business rules.
- `src/controllers/` call `prisma.user.create()` directly.
- `src/utils/` is imported by everything and contains framework-specific code.

### Agent guidance
When layers are not clearly separated:
1. Identify the **closest match** for each file based on path and content.
2. Flag the project as "transitional architecture" in `subjective_notes`.
3. Score should not be 0 if there is *some* attempt at separation, but should reflect the mixed state (typically 1.0–2.5).
4. `todo_desirable` should include high-priority items to extract layers.

---

## Framework Detection Table

| Framework | Source Root | Domain Indicator | Application Indicator | Interface Indicator |
|---|---|---|---|---|
| **NestJS** | `src/` | `*.entity.ts` + `@Entity()` | `*.service.ts` with `@Injectable()` | `*.controller.ts` + `@Controller()` |
| **Spring Boot** | `src/main/java/` | `domain/model/` package | `application/` package | `adapter/web/` or `controller/` package |
| **Laravel** | `app/` | `Domain/` namespace (if DDD) | `Application/` or `Services/` | `Http/Controllers/` |
| **Django** | `<app>/` | `models.py` (caveat: ORM) | `services.py` (if present) | `views.py`, `urls.py` |
| **FastAPI** | `app/` or `src/` | `domain/` folder | `application/` folder | `api/routes/` folder |
| **Express** | `src/` | `domain/` or `models/` (if pure) | `services/` or `use-cases/` | `routes/` or `controllers/` |
| **Next.js** | `app/` or `src/` | Rare; usually in `lib/domain/` | Rare; usually in `lib/services/` | `app/` (routes), `pages/` |
| **.NET Core** | `src/` | `Domain/Entities/` | `Application/UseCases/` | `API/Controllers/` |

---

> **Rule of thumb:** When in doubt, the agent should read the file content (using its own Read capability) to determine the actual layer, rather than relying solely on the folder name.
