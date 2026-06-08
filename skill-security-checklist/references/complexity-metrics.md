# Complexity Metrics Reference

## Cyclomatic Complexity

Measures the number of linearly independent paths through code.

**Formula:** M = E - N + 2P
- E = number of edges
- N = number of nodes
- P = number of connected components

**Interpretation:**

| Score | Risk Level | Action |
|-------|-----------|--------|
| 1-10 | Low | Simple, easy to test |
| 11-20 | Medium | Moderate risk, consider refactoring |
| 21-50 | High | Complex, hard to test, refactor |
| 50+ | Critical | Very risky, immediate refactoring needed |

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Objective | Mathematical, not subjective |
| Testable | Directly relates to test cases needed |
| Universal | Language-independent |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Narrow | Doesn't capture all complexity |
| Syntax | Can vary by counting method |
| Short circuits | switch/case can inflate score |

## Cognitive Complexity

Measures how difficult code is to understand.

**Rules:**
- No increment for method structure
- Increment for breaks in linear flow (if, loops, catch)
- Nested flow-break structures add nesting increment
- Increment for recursion, jumps to labels

**Interpretation:**

| Score | Risk Level | Action |
|-------|-----------|--------|
| 0-5 | Low | Easy to understand |
| 6-10 | Medium | Moderate cognitive load |
| 11-20 | High | Hard to understand, refactor |
| 20+ | Critical | Very difficult, immediate refactoring |

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Human-centric | Reflects mental effort |
| Nesting-aware | Penalizes deep nesting |
| Fair | Doesn't penalize method extraction |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Subjective | Based on human judgment |
| Tooling | Fewer tools support it |
| Learning | Requires understanding rules |

## Lines of Code (LOC)

Simple count of lines in a file/function.

**Interpretation:**

| Metric | Warning | Critical |
|--------|---------|----------|
| File length | > 300 lines | > 800 lines |
| Function length | > 50 lines | > 150 lines |
| Class length | > 300 lines | > 1000 lines |

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Simple | Easy to measure |
| Universal | Applies to all languages |
| Trend | Good for tracking over time |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Naive | Doesn't account for density |
| Style | Affected by formatting |
| Language | Varies significantly by language |

## Nesting Depth

Maximum level of conditional/loop nesting.

**Interpretation:**

| Depth | Risk Level | Action |
|-------|-----------|--------|
| 1-2 | Low | Normal |
| 3-4 | Medium | Consider extraction |
| 5-6 | High | Hard to follow, refactor |
| 6+ | Critical | Immediate refactoring |

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Intuitive | Easy to understand |
| Visual | Directly visible in code |
| Impact | Deeply nested code is hard to test |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Language | Some languages encourage nesting |
| False positives | Guard clauses vs deep logic |
| Context | Not all nesting is equal |

## Code Duplication

Percentage of code that appears more than once.

**Interpretation:**

| Percentage | Risk Level | Action |
|------------|-----------|--------|
| 0-5% | Low | Normal, some duplication acceptable |
| 5-15% | Medium | Review for abstraction opportunities |
| 15-25% | High | Significant duplication, refactor |
| 25%+ | Critical | Major duplication, immediate action |

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Objective | Measurable with tools |
| Impact | Direct correlation with maintenance cost |
| Clear | Easy to identify duplication blocks |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Threshold | What counts as duplication? |
| Boilerplate | Some duplication is intentional |
| Language | Token-based vs AST-based varies |

## Coupling Metrics

### Afferent Coupling (Ca)
Number of classes that depend on a given class.

### Efferent Coupling (Ce)
Number of classes that a given class depends on.

### Instability (I)
I = Ce / (Ca + Ce)
- I = 0: Max stable, many depend on it, depends on nothing
- I = 1: Max unstable, no one depends on it, depends on many

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Design | Measures architectural health |
| Targeted | Identifies problematic classes |
| Package-level | Works at package/module level |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Tooling | Requires static analysis tools |
| Context | High coupling may be justified |
| Dynamic | Doesn't capture runtime coupling |

## Test Coverage

Percentage of code covered by tests.

**Interpretation:**

| Coverage | Risk Level | Action |
|----------|-----------|--------|
| 80-100% | Low | Good coverage |
| 60-80% | Medium | Acceptable, improve critical paths |
| 40-60% | High | Poor coverage, add tests |
| 0-40% | Critical | Very risky, immediate testing needed |

**Pros:**
| Advantage | Description |
|-----------|-------------|
| Confidence | High coverage reduces regression risk |
| Refactoring | Enables safe refactoring |
| Documentation | Tests serve as documentation |

**Cons:**
| Disadvantage | Description |
|--------------|-------------|
| Metric | High coverage != good tests |
| Cost | Diminishing returns near 100% |
| Fragile | Coverage can be gamed |

## Recommended Thresholds by Language

| Language | Max Cyclomatic | Max Cognitive | Max File LOC | Max Function LOC |
|----------|---------------|---------------|--------------|------------------|
| JavaScript/TypeScript | 10 | 15 | 300 | 50 |
| Python | 10 | 15 | 300 | 50 |
| Go | 10 | 15 | 300 | 50 |
| Java | 10 | 15 | 400 | 50 |
| C# | 10 | 15 | 400 | 50 |
| C/C++ | 15 | 20 | 500 | 75 |
| Ruby | 10 | 15 | 300 | 50 |
| PHP | 10 | 15 | 300 | 50 |

## Tools for Measurement

| Tool | Languages | Metrics |
|------|-----------|---------|
| SonarQube | Multi | Cyclomatic, Cognitive, Duplication, Coverage |
| CodeClimate | Multi | Cyclomatic, Duplication, Churn |
| ESLint | JS/TS | Complexity, Max lines, Nesting |
| Pylint | Python | Cyclomatic, Refactoring, Nesting |
| golangci-lint | Go | Cyclomatic, Cognitive, Nesting |
| Checkstyle | Java | Cyclomatic, Nesting, File length |
| RuboCop | Ruby | Cyclomatic, Method length, Class length |
| PHPMD | PHP | Cyclomatic, Nesting, Excessive length |

## Interpretation Guidelines

1. **Combine metrics** - No single metric tells the whole story
2. **Trend over time** - Track metrics over releases, not just snapshots
3. **Context matters** - Generated code, boilerplate, and tests have different thresholds
4. **Focus on hotspots** - Prioritize files with multiple high metrics
5. **Automate** - Integrate metrics into CI/CD for continuous monitoring
