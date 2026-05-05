# DDD Pattern Library

> **Comprehensive reference for Domain-Driven Design patterns used in SDD.**

This library contains both strategic patterns (for system architecture) and tactical patterns (for code implementation).

---

## Strategic Patterns

Patterns for organizing the system architecture and defining boundaries.

| Pattern | Use When | Example |
|---------|----------|---------|
| **BOUNDED CONTEXT** | Clear linguistic boundaries exist | Catalog vs Inventory contexts |
| **CONTEXT MAP** | Multiple contexts interact | Sales ↔ Shipping relationship |
| **SHARED KERNEL** | Teams collaborate closely | Common types library |
| **CUSTOMER/SUPPLIER** | Clear upstream/downstream | Pricing API (upstream) |
| **CONFORMIST** | Can't influence upstream | Using external API as-is |
| **ANTI-CORRUPTION LAYER** | Legacy integration needed | Translating old to new model |
| **OPEN HOST SERVICE** | Providing standard protocol | Public API with standard interface |
| **PUBLISHED LANGUAGE** | Sharing formalized model | Event schemas, API contracts |
| **SEPARATE WAYS** | Integration cost > Duplication cost | Custom auth per service |

---

### Bounded Context

**Definition**: A defined boundary within which a particular domain model applies. Inside the boundary, all terms and concepts have precise meanings.

**Indicators you need separate bounded contexts:**
- Different teams using the same word with different meanings
- Same concept has different attributes in different parts of the system
- Natural organizational boundaries

**Example:**
```
┌─────────────────────────────────────┐
│  BOUNDED CONTEXT: Identity          │
│  ────────────────────────────────  │
│  User has: email, password,       │
│  verification status               │
└─────────────────────────────────────┘
           │
           │ UserId only
           ▼
┌─────────────────────────────────────┐
│  BOUNDED CONTEXT: Profile           │
│  ────────────────────────────────  │
│  User has: name, avatar, bio,     │
│  preferences                       │
└─────────────────────────────────────┘
```

---

### Context Map

**Definition**: A visual representation of the relationships between bounded contexts.

**Types of Relationships:**

```
┌─────────────────────────────────────────────────────────────┐
│                    CONTEXT MAP PATTERNS                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [Context A] ────────> [Context B]                          │
│     │                      │                                 │
│     │                      │                                 │
│     └── Partnership        └── Customer/Supplier            │
│         (collaboration)        (clear direction)             │
│                                                              │
│  [Context C] <══════════> [Context D]                       │
│     │  Shared Kernel         Published Language               │
│     │  (collaborate)         (formal contract)              │
│     │                                                        │
│     └── Conformist          Anti-Corruption Layer           │
│         (accept upstream)    (translate legacy)             │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Tactical Patterns

Patterns for implementing the domain model in code.

### Entity

**Definition**: An object that has a distinct identity that persists throughout the states of the application and over time.

**Characteristics:**
- Has global identity (ID)
- Identity matters even if all attributes change
- Mutable state
- Usually has a lifecycle

**Example:**
```typescript
// User is an Entity - same person even if name/email changes
class User {
  private id: UserId;        // Global identity
  private email: Email;
  private name: string;
  
  changeEmail(newEmail: Email): void {
    this.email = newEmail;   // Can mutate, still same User
  }
}
```

---

### Value Object

**Definition**: An object that describes some characteristic of a thing, with no conceptual identity. Compared by all attributes.

**Characteristics:**
- Immutable (create new instead of modifying)
- No identity
- Compared by all attributes
- Can be shared across entities

**Example:**
```typescript
// Money is a Value Object - $10 USD is always $10 USD
class Money {
  constructor(
    private readonly amount: number,
    private readonly currency: Currency
  ) {}
  
  add(other: Money): Money {
    if (this.currency !== other.currency) {
      throw new Error("Cannot add different currencies");
    }
    return new Money(this.amount + other.amount, this.currency);
  }
}
```

---

### Aggregate

**Definition**: A cluster of associated objects treated as a unit for data changes. Has a root entity (Aggregate Root) and clear boundaries.

**Rules (Non-Negotiable):**

1. **Transaction Boundary**: One transaction = One aggregate save
2. **Reference Rule**: 
   - Inside aggregate: Reference by object
   - Outside aggregate: Reference by ID only
3. **Delete Rule**: Delete aggregate = Delete everything inside
4. **Size Rule**: Start small, expand only when data proves need

**Example:**
```
┌─────────────────────────────────────┐
│  AGGREGATE: Order                    │
│  ─────────────────────────────────  │
│  Root: Order (Entity)               │
│  │                                  │
│  ├── OrderItem[] (Entities)        │
│  │   ├── ProductId (ref by ID)     │
│  │   ├── Quantity                  │
│  │   └── Money (Value Object)      │
│  │                                  │
│  ├── ShippingAddress (Value Object)│
│  └── OrderStatus (Value Object)     │
│                                    │
│  Invariants:                       │
│  - Total = sum of line totals       │
│  - Cannot modify shipped order     │
└─────────────────────────────────────┘
```

---

### Domain Event

**Definition**: Something that happened in the domain that the business cares about. Immutable record of past occurrence.

**Naming Convention**: `[Entity][Action]Occurred` or `[Entity][Action]Completed`

**Examples:**
- OrderPlaced
- PaymentReceived
- InventoryReserved
- ShipmentDispatched

**Content:**
- Event ID (UUID)
- Aggregate ID
- Timestamp (UTC)
- Version/Schema version
- Payload (minimal, event-specific data)
- Correlation ID (for distributed tracing)

**FANG Principles:**
- Events are facts - immutable and append-only
- Event schema evolution: Additive only (never delete fields)
- Include just enough data
- Idempotency keys for all handlers

---

### Domain Service

**Definition**: Business logic that doesn't naturally fit in an entity or value object. Stateless operations across multiple aggregates.

**When to use:**
- Operation involves multiple aggregates
- Business logic doesn't belong to any single entity
- Stateless calculation or coordination

**Example:**
```typescript
// Pricing Service doesn't belong to Order or Product
class PricingService {
  calculateOrderTotal(
    items: OrderItem[],
    customer: Customer,
    promotionCode?: string
  ): Money {
    // Complex pricing rules involving:
    // - Product base prices
    // - Customer tier discounts
    // - Active promotions
    // - Tax calculation
  }
}
```

---

### Repository

**Definition**: Abstracts persistence. Domain layer talks to interface, implementation in infrastructure.

**Responsibilities:**
- Persist aggregates
- Retrieve fully-hydrated aggregates
- Abstract query details

**Example:**
```typescript
// Interface in Domain layer
interface OrderRepository {
  save(order: Order): Promise<void>;
  findById(id: OrderId): Promise<Order | null>;
  findByCustomer(customerId: CustomerId): Promise<Order[]>;
}

// Implementation in Infrastructure layer
class PostgresOrderRepository implements OrderRepository {
  // SQL implementation details hidden from domain
}
```

---

### Factory

**Definition**: Encapsulates complex aggregate creation. Ensures invariants satisfied from birth.

**When to use:**
- Aggregate creation is complex
- Multiple ways to create same aggregate
- Need to validate invariants on creation

**Example:**
```typescript
class OrderFactory {
  createForCustomer(
    customerId: CustomerId,
    items: OrderItem[]
  ): Order {
    // Validate minimum order value
    // Validate items in stock
    // Apply default shipping method
    // Create order with initial state
    return new Order({
      id: OrderId.generate(),
      customerId,
      items,
      status: OrderStatus.PENDING,
      createdAt: new Date()
    });
  }
}
```

---

## Pattern Selection Guide

```
┌─────────────────────────────────────────────────────────────────┐
│  "Which pattern should I use?"                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Need to model a business concept that...                       │
│                                                                  │
│  ├─ Has identity that persists over time?                     │
│  │   └──► ENTITY                                               │
│  │                                                             │
│  ├─ Is described by attributes, no identity?                  │
│  │   └──► VALUE OBJECT                                         │
│  │                                                             │
│  ├─ Is a consistency boundary for transactions?               │
│  │   └──► AGGREGATE (with Entity as Root)                      │
│  │                                                             │
│  ├─ Represents something that happened?                       │
│  │   └──► DOMAIN EVENT                                         │
│  │                                                             │
│  ├─ Contains business logic spanning multiple aggregates?     │
│  │   └──► DOMAIN SERVICE                                       │
│  │                                                             │
│  ├─ Needs to be persisted/retrieved?                          │
│  │   └──► REPOSITORY (interface)                                │
│  │                                                             │
│  └─ Has complex creation logic?                                │
│      └──► FACTORY                                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Related Resources

- [DDD Tactics](ddd-tactics.md) - Detailed implementation guidance
- [Event Storming Guide](event-storming.md) - For discovering aggregates
- [Back to SKILL.md](../SKILL.md)
