# Code Smells and Anti-Patterns Catalog

## Code Smells

Code smells are surface indications that usually correspond to deeper problems in the system.

### Bloaters

**Long Method**
- Indicator: Function > 50 lines
- Risk: Hard to understand, test, and maintain
- Refactoring: Extract smaller functions

**Large Class (God Class)**
- Indicator: Class > 300 lines, many responsibilities
- Risk: Tight coupling, low cohesion
- Refactoring: Extract classes, apply Single Responsibility Principle

**Primitive Obsession**
- Indicator: Using primitives instead of value objects
- Risk: Validation scattered, domain concepts hidden
- Refactoring: Create value objects (Email, Money, PhoneNumber)

**Long Parameter List**
- Indicator: Function with > 5 parameters
- Risk: Hard to call, brittle to changes
- Refactoring: Introduce parameter object, use builder pattern

**Data Clumps**
- Indicator: Same group of variables passed together
- Risk: Duplication, missed abstraction
- Refactoring: Extract into a class

### Object-Oriented Abusers

**Switch Statements**
- Indicator: switch/case on type codes
- Risk: Open/Closed violation, scattered conditionals
- Refactoring: Polymorphism, strategy pattern

**Temporary Field**
- Indicator: Instance variables only used in some methods
- Risk: Confusing object lifecycle
- Refactoring: Extract class, introduce null object

**Refused Bequest**
- Indicator: Subclass ignores inherited methods
- Risk: Liskov Substitution violation
- Refactoring: Replace inheritance with composition

**Alternative Classes with Different Interfaces**
- Indicator: Two classes do similar things differently
- Risk: Duplication, inconsistent API
- Refactoring: Unify interfaces, extract common base

### Change Preventers

**Divergent Change**
- Indicator: One class changed for many different reasons
- Risk: Merge conflicts, regression risk
- Refactoring: Split class by responsibility

**Shotgun Surgery**
- Indicator: One change requires many small edits
- Risk: Missed changes, inconsistent state
- Refactoring: Move methods, consolidate behavior

**Parallel Inheritance Hierarchies**
- Indicator: Every subclass of A has a matching subclass of B
- Risk: Duplication, hard to maintain
- Refactoring: Merge hierarchies, use composition

### Dispensables

**Lazy Class**
- Indicator: Class with no real behavior
- Risk: Maintenance overhead
- Refactoring: Inline class, merge into caller

**Data Class**
- Indicator: Class with only getters and setters
- Risk: Anemic domain model
- Refactoring: Move behavior into class

**Duplicate Code**
- Indicator: Same code in multiple places
- Risk: Inconsistent changes, bugs
- Refactoring: Extract method, pull up to base class

**Dead Code**
- Indicator: Unused variables, methods, classes
- Risk: Confusion, maintenance burden
- Refactoring: Delete unused code

**Speculative Generality**
- Indicator: Abstractions for future needs that never came
- Risk: Unnecessary complexity
- Refactoring: Inline, remove unused layers

### Couplers

**Feature Envy**
- Indicator: Method uses more features of another class
- Risk: Tight coupling between classes
- Refactoring: Move method to the envied class

**Inappropriate Intimacy**
- Indicator: Classes with bidirectional dependencies
- Risk: Hard to change one without affecting other
- Refactoring: Extract common class, use facade

**Law of Demeter Violation**
- Indicator: Chaining calls (a.getB().getC().doSomething())
- Risk: Tight coupling to internal structure
- Refactoring: Tell, don't ask; hide internal structure

**Message Chains**
- Indicator: Long chain of object navigation
- Risk: Fragile to structural changes
- Refactoring: Hide delegate, add facade

**Middle Man**
- Indicator: Class delegates all work to another class
- Risk: Unnecessary indirection
- Refactoring: Remove middleman, inline calls

## Anti-Patterns

### Architectural Anti-Patterns

**Big Ball of Mud**
- No discernible architecture
- Haphazard structure, no layers
- Risk: Unmaintainable, impossible to reason about

**Architecture by Implication**
- No explicit architecture decisions
- Grew organically without planning
- Risk: Inconsistent patterns, technical debt

**Vendor Lock-In**
- Heavy dependence on specific vendor APIs
- No abstraction layer
- Risk: Expensive to migrate, limited flexibility

### Design Anti-Patterns

**Golden Hammer**
- Using favorite tool/pattern for every problem
- Risk: Suboptimal solutions, over-engineering

**Reinventing the Wheel**
- Building custom solutions for solved problems
- Risk: Bugs, maintenance, missed best practices

**Spaghetti Code**
- Tangled control flow, no structure
- Risk: Unreadable, untestable, fragile

**Copy-Paste Programming**
- Duplicating code instead of abstracting
- Risk: Inconsistency, bugs, maintenance burden

**Boat Anchor**
- Keeping unused or obsolete code/components
- Risk: Confusion, build time, dependency issues

**Lava Flow**
- Dead code that no one dares to remove
- Risk: Maintenance burden, misleading

### Testing Anti-Patterns

**Fragile Test**
- Tests break on unrelated changes
- Risk: Low confidence, high maintenance

**Mock Overuse**
- Everything mocked, testing implementation
- Risk: Tests don't verify real behavior

**Test After**
- Writing tests after implementation
- Risk: Hard to test, coverage gaps

**No Tests**
- No automated tests at all
- Risk: Regression bugs, fear of refactoring

## Detection Thresholds

| Smell | Warning Threshold | Critical Threshold |
|-------|-------------------|-------------------|
| Long Method | > 50 lines | > 150 lines |
| Large Class | > 300 lines | > 1000 lines |
| Long Parameter List | > 5 params | > 10 params |
| Code Duplication | > 10% duplicated | > 25% duplicated |
| Cyclomatic Complexity | > 10 | > 20 |
| Cognitive Complexity | > 15 | > 30 |
| Nesting Depth | > 4 levels | > 6 levels |
| File Length | > 300 lines | > 800 lines |

## Refactoring Priority

| Priority | Condition |
|----------|-----------|
| **P0** | Critical security risks, data loss bugs |
| **P1** | High complexity, missing tests on critical paths |
| **P2** | Code duplication, long methods, naming issues |
| **P3** | Style inconsistencies, minor smells |
