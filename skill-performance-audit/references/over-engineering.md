# Over-Engineering Reference

Guide for identifying unnecessary complexity, premature abstractions, and architectural overhead that costs more than it delivers.

---

## Core Principle: Match Complexity to the Problem

> "Make it work, make it right, make it fast — in that order." — Kent Beck

Over-engineering is the introduction of solutions to problems that do not yet exist. It is not a style issue — it is a **maintenance cost** issue. Every abstraction layer added is a layer every future developer must understand, debug, and keep updated.

### The Cost of Every Abstraction
- One more file to open when debugging
- One more thing to mock in tests
- One more surface area for bugs
- One more concept for new team members to learn

---

## Empty Abstractions (Pass-Through Layers) {#empty-abstractions}

### What It Is
An abstraction layer that adds indirection without adding any behavior — no validation, no error transformation, no business logic, no mapping. It delegates directly to the next layer.

### Why It Exists (and Why That's Not Enough)
Teams add empty layers "for future flexibility" or to follow a pattern they read about. But flexibility that is never used is indirection without value.

### Detection Heuristic
**If deleting the class and calling its dependency directly would change zero behavior, the class adds no value.**

```typescript
// BEFORE — 3 files, 0 added value
// user.controller.ts
async getUser(req) {
  return this.userService.getUser(req.params.id);
}

// user.service.ts
async getUser(id: string) {
  return this.userRepository.findById(id); // no logic added
}

// user.repository.ts
async findById(id: string) {
  return this.prisma.user.findUnique({ where: { id } }); // wraps ORM
}

// AFTER — controller calls ORM directly (acceptable for simple CRUD)
async getUser(req) {
  return db.user.findUnique({ where: { id: req.params.id } });
}
```

### When Layers ARE Justified
- **Service layer**: add it when there is business logic (validation, rules, transformations)
- **Repository layer**: add it when you need to swap databases, or when query logic is complex enough to test in isolation
- **Controller layer**: always justified — HTTP concerns belong here

### Rule
A service should do at least ONE of: validate, transform, enforce a business rule, call multiple repositories, handle errors specifically. If it does none of these, it is pass-through.

---

## Premature Generalization {#premature-generalization}

### What It Is
Building a system flexible enough for 10 different use cases when only 1 exists today — and the other 9 are speculative.

### The YAGNI Principle
**You Ain't Gonna Need It.** Every configurable parameter, every plugin hook, every strategy interface has a maintenance cost. If it is not used today, the cost is paid for nothing.

### Detection Heuristic
- A function has 5+ optional parameters
- The non-default usage is 0 or 1 call site
- The README says "this will be useful when we need to..."

```typescript
// BEFORE — 7 options, all always at their defaults
interface SendEmailOptions {
  from?: string;       // always 'noreply@company.com'
  replyTo?: string;    // never set
  cc?: string[];       // never set
  bcc?: string[];      // never set
  priority?: 'high' | 'normal' | 'low'; // always 'normal'
  template?: string;   // always 'default'
  attachments?: Attachment[]; // never set
}

async function sendEmail(to: string, subject: string, body: string, options: SendEmailOptions = {}) {
  // 50 lines of option-handling code
}

// Called as:
await sendEmail(user.email, 'Welcome!', 'Hello!');
// Options never used anywhere.

// AFTER — simple function matching actual usage
async function sendEmail(to: string, subject: string, body: string) {
  // 10 lines
}
// Add options only when a second real call site actually needs them
```

### When Generalization IS Justified
- There are 3+ existing call sites with different parameters
- The extension point is part of a public API/SDK
- A product requirement specifies it (not a guess)

---

## Premature Infrastructure {#premature-infrastructure}

### What It Is
Introducing infrastructure (message queues, event buses, service meshes, microservices) to solve a scaling problem that has not been measured or proven to exist.

### The Real Cost of Early Infrastructure

| Infrastructure | What it adds |
|---|---|
| Message queue (RabbitMQ/SQS) | Async complexity, ordering guarantees, dead-letter queues, monitoring |
| Microservices split | Network latency between services, distributed transactions, separate deployments, independent databases |
| CQRS | Separate read/write models, eventual consistency, more code paths to maintain |
| Event bus | Event schema versioning, consumer registration, debugging becomes tracing-dependent |

### Detection Pattern — Queue That Could Be a Function Call

```typescript
// BEFORE — queue for a single sequential action
await eventBus.publish('user.registered', { userId: user.id });
// ... in consumer ...
eventBus.subscribe('user.registered', async ({ userId }) => {
  await emailService.sendWelcome(userId);
  await analyticsService.track('signup', userId);
});

// AFTER — direct call is simpler, faster, and easier to debug
await createUserUseCase.execute(userData);
await emailService.sendWelcome(user.id);       // sequential, debuggable
await analyticsService.track('signup', user.id);
// Add a queue ONLY when: these need to be non-blocking AND failures need retry logic
```

### Detection Pattern — Microservices With Shared Database

```typescript
// This negates the core benefit of microservices:
// Service A and Service B both connect to the same PostgreSQL database
// → they are NOT independent; schema changes in one break the other
// → you have operational complexity of microservices with no isolation benefit
```

### Justified Infrastructure Triggers
Only recommend infrastructure when a **measured problem** exists:
- Queue: tasks take >500ms AND blocking the request is a user experience problem
- Microservices: a specific service has independent scaling needs, independent deployment frequency, or an independent team
- CQRS: read and write loads are measured to be asymmetric (e.g., 100:1 read/write ratio)
- Event bus: more than 2 consumers need to react to the same event independently

---

## Unnecessary Design Patterns {#unnecessary-patterns}

### What It Is
Applying Gang-of-Four or enterprise patterns to scenarios too simple to benefit from them — adding indirection and boilerplate without solving a real problem.

### Pattern Justification Matrix

| Pattern | Justified when... | NOT justified when... |
|---|---|---|
| Factory | There are 3+ implementations, or instantiation logic is complex | There is 1 implementation and `new Foo()` works fine |
| Strategy | There are 3+ interchangeable algorithms used at runtime | There are 2 cases that can be a simple if/else or ternary |
| Observer / Event | Multiple independent systems need to react to the same event | One system reacts; a direct call is simpler |
| Decorator | Behavior must be composed dynamically at runtime | Behavior is fixed; just add it to the class directly |
| Unit of Work | Multiple repositories must be coordinated; ORM doesn't handle it | A single `$transaction` in Prisma or TypeORM already handles it |
| Repository | Query logic is complex or testable in isolation; DB might change | Simple ORM calls that take 1-2 lines directly |

### Factory Anti-Pattern Example

```typescript
// BEFORE — Factory for a class with a single, unchanging implementation
interface IUserFactory {
  create(data: CreateUserDto): User;
}

class UserFactory implements IUserFactory {
  create(data: CreateUserDto): User {
    return new User(data.id, data.email, data.name);
  }
}

// Used as:
const factory = new UserFactory();
const user = factory.create(dto);

// AFTER — just use new directly
const user = new User(dto.id, dto.email, dto.name);
// Add a Factory only when: instantiation requires async setup, external config,
// or there are multiple User subtypes selected at runtime
```

### Strategy Anti-Pattern Example

```typescript
// BEFORE — Strategy pattern for a binary choice
interface ISortStrategy {
  sort(items: Item[]): Item[];
}
class AscendingSort implements ISortStrategy {
  sort(items: Item[]) { return [...items].sort((a, b) => a.name.localeCompare(b.name)); }
}
class DescendingSort implements ISortStrategy {
  sort(items: Item[]) { return [...items].sort((a, b) => b.name.localeCompare(a.name)); }
}
class Sorter {
  constructor(private strategy: ISortStrategy) {}
  sort(items: Item[]) { return this.strategy.sort(items); }
}
// Used as: new Sorter(new AscendingSort()).sort(items)

// AFTER — just use a parameter
function sortItems(items: Item[], direction: 'asc' | 'desc' = 'asc'): Item[] {
  return [...items].sort((a, b) =>
    direction === 'asc'
      ? a.name.localeCompare(b.name)
      : b.name.localeCompare(a.name)
  );
}
```

### How to Recognize Justified Patterns
Ask these questions before introducing a pattern:
1. **How many implementations exist today?** (< 2 = probably not needed)
2. **Will they change independently?** (No = probably not needed)
3. **Is this driven by a product requirement or anticipation?** (Anticipation = YAGNI)
4. **Does removing the pattern require rewriting the call sites?** (No = the abstraction adds no value)
