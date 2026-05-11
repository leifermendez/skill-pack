# Scoring Matrix

The agent computes the final score using this rubric.

## Base Score Calculation

1. Start from **max_score = 5**.
2. Apply deductions from **Hard Violations** (automated by scripts).
3. Apply deductions from **Subjective Findings** (agent judgment).
4. Floor at **0**.

---

## Hard Violations Deductions (weight ~70% of total)

| Violation Type | Deduction | Notes |
|---|---|---|
| Domain imports Infrastructure / Interface / Application | -2.0 | Critical: innermost layer is corrupted |
| Application imports Infrastructure / Interface | -1.5 | Use case layer bypassed |
| Interface imports Domain / Infrastructure | -1.5 | Presentation reaches too deep |
| Infrastructure imports Interface | -1.0 | Adapter depends on presentation |
| Circular dependency between layers | -1.0 | Any cycle |
| Missing Domain layer entirely | -2.0 | Cannot have Clean Arch without Domain |
| Missing Application layer entirely | -1.5 | No use cases / orchestration |
| Missing Infrastructure adapter entirely | -0.5 | Acceptable for tiny libraries, bad for services |
| Repository interface NOT in Domain | -0.5 | Port belongs inside |
| Repository implementation in Domain | -1.0 | Implementation leaks into core |
| Missing LAYER headers in >50% files | -0.5 | Documentation hygiene |

### Hard Score Subtotal
```
hard_score = 5 - sum(deductions)
hard_score = max(0, hard_score)
```

---

## Subjective Findings Deductions (weight ~30% of total)

| Finding | Deduction | Notes |
|---|---|---|
| Business logic in Controllers / Interface | -1.0 | Controllers should delegate |
| Business logic in Infrastructure services | -0.5 | Domain or Application should own it |
| Anemic Domain Model (entities are data bags) | -0.5 | Missing behavior in entities |
| ORM models used as Domain entities | -1.0 | Leaky abstraction |
| DTOs contain nested ORM objects | -0.5 | DTOs must be flat |
| God use case (>200 lines or >5 dependencies) | -0.5 | Split responsibility |
| Mixed naming conventions in same project | -0.5 | Consistency matters |
| No constructor injection / composition root | -0.5 | Hard to test |
| Missing repository interface for aggregate | -0.5 | Every aggregate needs a port |
| Files with multiple responsibilities | -0.5 | One class / interface per file |
| Application use case contains business rules | -0.5 | Should orchestrate only |

### Subjective Score Subtotal
```
subjective_score = 5 - sum(deductions)
subjective_score = max(0, subjective_score)
```

---

## Final Score Formula

```
score = round( (hard_score * 0.70) + (subjective_score * 0.30), 1 )
score = max(0, min(5, score))
```

Rounding is to **1 decimal place**.

---

## Score Interpretation Table

| Score | Label | Meaning |
|---|---|---|
| 5.0 | **Excellent** | All hard rules pass. Naming consistent. Zero subjective issues. Ready for production. |
| 4.0 - 4.9 | **Good** | All hard rules pass. Minor subjective issues (missing headers, small naming gaps). |
| 3.0 - 3.9 | **Fair** | Core hard rules OK. Missing documented layers or naming inconsistencies. Needs cleanup. |
| 2.0 - 2.9 | **Poor** | Significant dependency violations (Domain imports Infra, Controller calls DB directly). Requires refactoring plan. |
| 1.0 - 1.9 | **Bad** | Layer structure barely exists. Naming conventions largely ignored. Major overhaul needed. |
| 0.0 - 0.9 | **No attempt** | No Clean Architecture / DDD structure detectable. Greenfield or legacy spaghetti. |

---

## Score Mapping for CI/CD Gates

| Gate | Minimum Score |
|---|---|
| `strict` | 4.0 |
| `moderate` | 3.0 |
| `lenient` | 2.0 |
| `report-only` | 0.0 |

The agent includes the gate name in `metadata.gate` if provided.

---

## Examples

### Example A: Perfect project
- Hard: 0 deductions → hard_score = 5.0
- Subjective: 0 deductions → subjective_score = 5.0
- **Final: (5.0 * 0.7) + (5.0 * 0.3) = 5.0**

### Example B: Domain imports Prisma, anemic models, logic in controller
- Hard: Domain imports Infra (-2.0), missing headers (-0.5) → hard_score = 2.5
- Subjective: logic in controller (-1.0), anemic models (-0.5) → subjective_score = 3.5
- **Final: (2.5 * 0.7) + (3.5 * 0.3) = 1.75 + 1.05 = 2.8 → rounds to 2.8**

### Example C: No layers at all
- Hard: missing Domain (-2.0), missing Application (-1.5) → hard_score = 1.5
- Subjective: mixed naming (-0.5), no DI (-0.5) → subjective_score = 4.0 (only because there is nothing else to judge)
- **Final: (1.5 * 0.7) + (4.0 * 0.3) = 1.05 + 1.20 = 2.25 → rounds to 2.3**

---

> **Note:** The agent may adjust the final score by ±0.1 based on holistic project size and context. A 2-file library is judged less harshly than a 200-file service.
