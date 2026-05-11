# Validation Rules for Tools

This document defines the exact rules that the `tools/*.sh` scripts enforce.
All scripts are 100% bash and produce YAML output to stdout.

---

## 1. Source Discovery

### Candidate folders (checked in order)
1. `src/`
2. `source/`
3. `app/`
4. `lib/`
5. `src/main/java/` (Maven/Gradle)
6. `src/app/` (Angular/NestJS)
7. `packages/*/src/` (monorepo)
8. Root-level `.ts`, `.js`, `.java`, `.py`, `.go`, `.php`, `.cs` files

### Selection criteria
- Count files with extensions: `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.java`, `.py`, `.go`, `.php`, `.cs`
- Choose the folder with the highest count.
- If tie, prefer `src/` > `app/` > `source/` > `lib/`.

---

## 2. Layer Discovery

### Recognized layer folder names (case-insensitive)

| Canonical Layer | Accepted Folder Names |
|---|---|
| Domain | `domain`, `domains`, `core`, `entities`, `model`, `models` |
| Application | `application`, `app`, `applications`, `services`, `service` |
| UseCases | `usecases`, `use-cases`, `use_cases`, `uc`, `interactors`, `features` |
| Infrastructure | `infrastructure`, `infra`, `infrastructures`, `adapter`, `adapters`, `persistence`, `db`, `data`, `external` |
| Interface | `interface`, `interfaces`, `presenters`, `controllers`, `api`, `http`, `rest`, `web`, `cli` |
| Presentation | `presentation`, `presentations`, `ui`, `view`, `views` |

### Ambiguity resolution
- If both `app/` (Application) and `app/` (top-level Next.js) exist, use deepest nested one that contains subfolders matching other layer names.
- `src/app/` in Next.js is **Interface**, not Application, unless it contains `use-cases/` or `domain/` subfolders.
- `presentation/`, `ui/`, `views/` are mapped to canonical layer **Presentation** (role: Interface).
- `@services/` is **not** a standard Clean Architecture layer. Default classification: **Infrastructure** (concrete external adapters). Reclassify to **Application** only if it contains pure orchestration services.

---

## 3. File Classification

### Responsibility type detection (by path + filename)

| Type | Path contains | Filename contains |
|---|---|---|
| `entity` | `entities/`, `entity/`, `model/`, `models/` | `.entity.`, `.model.` |
| `value-object` | `value-objects/`, `vo/`, `valueObjects/` | `.vo.`, `.value.` |
| `repository-interface` | `repositories/`, `repo/`, `ports/` | `.repository.interface.`, `.repo.interface.`, `.port.` |
| `repository-impl` | `repositories/`, `repo/`, `persistence/`, `database/`, `db/` | `.repository.`, `.repo.`, `.impl.` |
| `use-case` | `use-cases/`, `usecases/`, `uc/`, `interactors/`, `features/` | `.use-case.`, `.usecase.`, `.uc.`, `.interactor.` |
| `dto` | `dtos/`, `dto/` | `.dto.`, `.request.`, `.response.`, `.command.`, `.query.` |
| `controller` | `controllers/`, `controller/`, `handlers/`, `routes/` | `.controller.`, `.handler.`, `.route.`, `.router.` |
| `service-domain` | `services/`, `domain-services/`, `domainService/` | `.domain.service.`, `.domain-service.` |
| `service-infra` | `services/` (inside Infra) | `.service.` |
| `mapper` | `mappers/`, `mapper/`, `transformers/` | `.mapper.`, `.transform.` |
| `config` | `config/`, `configuration/`, `env/` | `.config.`, `.env.` |
| `middleware` | `middlewares/`, `middleware/`, `interceptors/` | `.middleware.`, `.interceptor.`, `.guard.` |
| `port` | `ports/` | `.port.`, `.interface.` (when inside Application) |
| `adapter` | `adapters/` | `.adapter.` |
| `event` | `events/`, `domain-events/` | `.event.`, `.events.` |
| `generic` | anything else | anything else |

### Language detection by extension

| Extension | Language |
|---|---|
| `.ts`, `.tsx` | typescript |
| `.js`, `.jsx`, `.mjs` | javascript |
| `.java` | java |
| `.py` | python |
| `.go` | go |
| `.php` | php |
| `.cs` | csharp |

---

## 4. Import Extraction by Language

### TypeScript / JavaScript
```regex
import\s+.*?\s+from\s+['"](.+?)['"]
```
Also support:
```regex
require\(['"](.+?)['"]\)
```

### Java
```regex
import\s+(.+?);
```
Skip `import static` for simplicity (or include with flag).

### Python
```regex
from\s+(.+?)\s+import
import\s+(.+)
```

### PHP
```regex
use\s+(.+?);
```

### Go
```regex
import\s+["'](.+?)["']
```

### C#
```regex
using\s+(.+?);
```

### Relative import detection
- Starts with `./`, `../`, or (for Java) no package prefix.
- For Go: starts with project module name = absolute; otherwise relative.

---

## 5. Dependency Validation Rules

### Allowed imports matrix

| Source Layer \ Target Layer | Domain | Application | UseCases | Infrastructure | Interface |
|---|---|---|---|---|---|
| **Domain** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Application** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **UseCases** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Infrastructure** | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Interface** | ❌ | ✅ | ✅ | ❌ | ✅ |

Legend:
- ✅ Allowed
- ❌ Forbidden (hard violation)

### Special cases
- **Application importing UseCases**: treat as Application → Application (allowed if UseCases is considered part of Application).
- **Interface importing UseCases directly**: treat as Interface → Application (allowed).
- **Infrastructure importing Interface**: always critical violation.
- **Domain importing anything outside Domain**: always critical violation.

### Severity mapping

| Violation | Severity |
|---|---|
| Domain imports outer layer | critical |
| Application imports Infrastructure/Interface | critical |
| Infrastructure imports Interface | critical |
| Interface imports Domain/Infrastructure | critical |
| Circular dependency between layers | high |
| UseCases imports Infrastructure/Interface | high |

---

## 6. Naming Conventions

### Required patterns by layer and type

| Layer | Type | Expected Filename Pattern |
|---|---|---|
| Domain | entity | `*.entity.{ext}` or `*/entities/*.{ext}` |
| Domain | value-object | `*.vo.{ext}` or `*/value-objects/*.{ext}` |
| Domain | repository-interface | `*.repository.interface.{ext}` or `*.port.{ext}` |
| Domain | domain-service | `*.domain.service.{ext}` |
| Application | use-case | `*.use-case.{ext}` or `*.usecase.{ext}` |
| Application | dto | `*.dto.{ext}` or `*.request.{ext}` or `*.response.{ext}` |
| Application | port | `*.port.{ext}` |
| Infrastructure | repository-impl | `*.repository.{ext}` (but NOT `.interface.`) |
| Infrastructure | service-infra | `*.service.{ext}` |
| Infrastructure | adapter | `*.adapter.{ext}` |
| Interface | controller | `*.controller.{ext}` or `*.handler.{ext}` |
| Interface | middleware | `*.middleware.{ext}` |

### Style preferences (subjective, but flagged by script)
- **Preferred**: kebab-case (`create-user.use-case.ts`)
- **Acceptable**: camelCase (`createUserUseCase.ts`) — flagged as `medium` issue
- **Discouraged**: snake_case (`create_user_use_case.ts`) — flagged as `medium` issue

---

## 7. Logic Leak Detection (Heuristics)

### Keywords searched in Interface / Controller / Presentation files

```
calculate
validate
compute
process
transform
business
rule
apply.*discount
apply.*tax
if.*amount
if.*balance
if.*total
fee
commission
tax
discount
interest
rate
```

### Severity
- **high**: keyword appears in a Controller / Route / Handler / View.
- **medium**: keyword appears in an Infrastructure service (should be in Domain or Application).

---

## 8. Output Format for Scripts

Every script must output **valid YAML** to stdout.
- Strings with special chars must be quoted.
- Arrays use `- ` list syntax.
- Objects use `key: value`.
- No trailing whitespace.
- UTF-8 encoding.
