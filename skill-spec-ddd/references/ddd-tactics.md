# DDD Tactics Quick Reference

> **Implementation-level guidance for DDD patterns.**

Quick reference for applying Domain-Driven Design patterns in your code.

---

## Aggregate Rules (Non-Negotiable)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AGGREGATE DESIGN PRINCIPLES                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. TRANSACTION BOUNDARY                                                     │
│     ┌─────────────────┐                                                      │
│     │   AGGREGATE     │  One transaction = One aggregate save               │
│     │  ┌───────────┐  │                                                      │
│     │  │  Root     │  │  Root Entity: Has global identity                  │
│     │  │  Entity   │  │                                                      │
│     │  └─────┬─────┘  │  Invariants enforced across entire boundary       │
│     │  ┌─────┴─────┐  │                                                      │
│     │  │ Entities  │  │  Child Entities: Local identity only             │
│     │  │  (1..*)   │  │                                                      │
│     │  ├───────────┤  │  Value Objects: Immutable, replace not modify       │
│     │  │ Value Obj │  │                                                      │
│     │  │  (0..*)   │  │                                                      │
│     │  └───────────┘  │                                                      │
│     └─────────────────┘                                                      │
│                                                                              │
│  2. REFERENCE RULE                                                           │
│     • Inside aggregate: Reference by object                                   │
│     • Outside aggregate: Reference by ID only                               │
│                                                                              │
│  3. DELETE RULE                                                              │
│     • Delete aggregate = Delete everything inside                           │
│     • Orphaned entities should not exist                                    │
│                                                                              │
│  4. SIZE RULE                                                                │
│     • Small aggregates: Better performance, less contention                 │
│     • Large aggregates: More consistency, more locking                      │
│     • "FANG Rule": Start small, expand only when data proves need          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Domain Event Best Practices

### Naming Convention

**Format**: `[Entity][Action]Occurred` or `[Entity][Action]Completed`

**Examples:**
- ✅ OrderPlaced
- ✅ PaymentReceived  
- ✅ InventoryReserved
- ✅ ShipmentDispatched
- ❌ OrderPlacement (not past tense)
- ❌ PlaceOrder (this is a command, not event)

---

### Event Structure

```typescript
interface DomainEvent {
  // Required fields
  eventId: UUID;           // Unique event identifier
  aggregateId: UUID;       // ID of the aggregate that produced it
  occurredOn: Date;        // Timestamp (UTC)
  eventType: string;       // Event type name
  
  // Recommended fields
  version: number;         // Schema version for evolution
  correlationId: UUID;      // For distributed tracing
  causationId: UUID;       // ID of event that caused this one
  
  // Payload - event-specific data
  payload: {
    // Only include data needed by consumers
    // Don't include full aggregate state
  };
}
```

---

### Event Publishing

**In Aggregate:**
```typescript
class Order extends AggregateRoot {
  private events: DomainEvent[] = [];
  
  ship(): void {
    if (this.status !== OrderStatus.PAID) {
      throw new DomainException("Cannot ship unpaid order");
    }
    
    this.status = OrderStatus.SHIPPED;
    this.occurredOn = new Date();
    
    // Publish event
    this.addEvent(new OrderShipped({
      orderId: this.id,
      shippedAt: this.occurredOn,
      trackingNumber: this.trackingNumber
    }));
  }
  
  private addEvent(event: DomainEvent): void {
    this.events.push(event);
  }
  
  getUncommittedEvents(): DomainEvent[] {
    return [...this.events];
  }
  
  markEventsAsCommitted(): void {
    this.events = [];
  }
}
```

---

## Value Object Implementation

### Characteristics

1. **Immutable**: Never modify, always create new
2. **No Identity**: Compared by all attributes
3. **Self-Validating**: Constructor validates invariants
4. **Side-Effect Free**: Methods return new instances

### Example: Money

```typescript
class Money {
  public readonly amount: number;
  public readonly currency: string;
  
  constructor(amount: number, currency: string) {
    if (amount < 0) {
      throw new DomainException("Money cannot be negative");
    }
    if (!currency || currency.length !== 3) {
      throw new DomainException("Invalid currency code");
    }
    
    this.amount = amount;
    this.currency = currency.toUpperCase();
    
    Object.freeze(this); // Ensure immutability
  }
  
  // Operations return new instances
  add(other: Money): Money {
    this.ensureSameCurrency(other);
    return new Money(this.amount + other.amount, this.currency);
  }
  
  subtract(other: Money): Money {
    this.ensureSameCurrency(other);
    const result = this.amount - other.amount;
    if (result < 0) {
      throw new DomainException("Insufficient funds");
    }
    return new Money(result, this.currency);
  }
  
  multiply(factor: number): Money {
    return new Money(this.amount * factor, this.currency);
  }
  
  // Comparison
  equals(other: Money): boolean {
    return this.amount === other.amount && 
           this.currency === other.currency;
  }
  
  greaterThan(other: Money): boolean {
    this.ensureSameCurrency(other);
    return this.amount > other.amount;
  }
  
  private ensureSameCurrency(other: Money): void {
    if (this.currency !== other.currency) {
      throw new DomainException(
        `Cannot operate on different currencies: ${this.currency} vs ${other.currency}`
      );
    }
  }
  
  toString(): string {
    return `${this.currency} ${this.amount.toFixed(2)}`;
  }
}
```

---

## Entity Implementation

### Characteristics

1. **Global Identity**: Unique ID across the system
2. **Mutable State**: Can change over time
3. **Equality by ID**: Same ID = same entity
4. **Lifecycle**: Created, modified, archived/deleted

### Example: User Entity

```typescript
class User extends Entity {
  private email: Email;
  private name: string;
  private verificationStatus: VerificationStatus;
  private updatedAt: Date;
  
  constructor(
    id: UserId,
    email: Email,
    name: string
  ) {
    super(id);
    this.email = email;
    this.name = name;
    this.verificationStatus = VerificationStatus.PENDING;
    this.updatedAt = new Date();
  }
  
  // Business methods (not anemic model)
  changeEmail(newEmail: Email): void {
    if (this.verificationStatus === VerificationStatus.BANNED) {
      throw new DomainException("Banned users cannot change email");
    }
    
    this.email = newEmail;
    this.verificationStatus = VerificationStatus.PENDING;
    this.updatedAt = new Date();
    
    this.addEvent(new UserEmailChanged({
      userId: this.id,
      oldEmail: this.email,
      newEmail: newEmail
    }));
  }
  
  verifyEmail(): void {
    if (this.verificationStatus !== VerificationStatus.PENDING) {
      throw new DomainException("Email is not pending verification");
    }
    
    this.verificationStatus = VerificationStatus.VERIFIED;
    this.updatedAt = new Date();
    
    this.addEvent(new UserEmailVerified({
      userId: this.id,
      email: this.email
    }));
  }
  
  // Getters for read access
  getEmail(): Email { return this.email; }
  getName(): string { return this.name; }
  getVerificationStatus(): VerificationStatus { 
    return this.verificationStatus; 
  }
}
```

---

## Repository Pattern

### Interface (Domain Layer)

```typescript
// repository.ts - Domain layer
interface OrderRepository {
  // Commands
  save(order: Order): Promise<void>;
  
  // Queries
  findById(id: OrderId): Promise<Order | null>;
  findByCustomerId(customerId: CustomerId): Promise<Order[]>;
  findPendingOrders(): Promise<Order[]>;
  
  // Existence check
  exists(orderId: OrderId): Promise<boolean>;
  
  // Count
  countByCustomer(customerId: CustomerId): Promise<number>;
}
```

### Implementation (Infrastructure Layer)

```typescript
// postgres-order-repository.ts - Infrastructure layer
class PostgresOrderRepository implements OrderRepository {
  constructor(
    private db: Database,
    private eventBus: EventBus,
    private mapper: OrderMapper
  ) {}
  
  async save(order: Order): Promise<void> {
    const persisted = await this.db.orders.upsert({
      where: { id: order.getId().toString() },
      data: this.mapper.toPersistence(order)
    });
    
    // Publish domain events
    const events = order.getUncommittedEvents();
    for (const event of events) {
      await this.eventBus.publish(event);
    }
    order.markEventsAsCommitted();
  }
  
  async findById(id: OrderId): Promise<Order | null> {
    const data = await this.db.orders.findUnique({
      where: { id: id.toString() },
      include: { items: true, shippingAddress: true }
    });
    
    if (!data) return null;
    
    return this.mapper.toDomain(data);
  }
  
  async findByCustomerId(customerId: CustomerId): Promise<Order[]> {
    const data = await this.db.orders.findMany({
      where: { customerId: customerId.toString() },
      include: { items: true }
    });
    
    return data.map(d => this.mapper.toDomain(d));
  }
  
  // ... other methods
}
```

---

## Anti-Patterns to Avoid

### ❌ Anemic Domain Model

```typescript
// BAD: Entity is just data holder
class Order {
  id: string;
  status: string;
  total: number;
  // No business logic, just getters/setters
}

// Business logic scattered in services
class OrderService {
  calculateTotal(order: Order): number {
    // Logic that should be in Order aggregate
  }
}
```

### ✅ Rich Domain Model

```typescript
// GOOD: Entity encapsulates business logic
class Order extends AggregateRoot {
  private status: OrderStatus;
  private items: OrderItem[];
  
  addItem(product: Product, quantity: number): void {
    if (this.status !== OrderStatus.DRAFT) {
      throw new DomainException("Cannot modify submitted order");
    }
    
    const existingItem = this.findItem(product.getId());
    if (existingItem) {
      existingItem.increaseQuantity(quantity);
    } else {
      this.items.push(new OrderItem(product, quantity));
    }
    
    this.recalculateTotal();
  }
  
  getTotal(): Money {
    return this.items.reduce(
      (sum, item) => sum.add(item.getSubtotal()),
      Money.zero()
    );
  }
}
```

---

### ❌ Violating Aggregate Boundaries

```typescript
// BAD: Accessing another aggregate's internals
class OrderService {
  async processOrder(orderId: OrderId): Promise<void> {
    const order = await this.orderRepo.findById(orderId);
    const customer = await this.customerRepo.findById(order.customerId);
    
    // Directly modifying another aggregate!
    customer.loyaltyPoints += order.getTotal() / 100;
    await this.customerRepo.save(customer);
  }
}
```

### ✅ Using Domain Events

```typescript
// GOOD: Let aggregates communicate via events
class Order extends AggregateRoot {
  complete(): void {
    this.status = OrderStatus.COMPLETED;
    
    // Publish event instead of direct modification
    this.addEvent(new OrderCompleted({
      orderId: this.id,
      customerId: this.customerId,
      total: this.getTotal()
    }));
  }
}

// Event handler in another bounded context
class OrderCompletedHandler {
  async handle(event: OrderCompleted): Promise<void> {
    const customer = await this.customerRepo.findById(event.customerId);
    customer.addLoyaltyPoints(event.total.dividedBy(100));
    await this.customerRepo.save(customer);
  }
}
```

---

## Related Resources

- [DDD Pattern Library](ddd-pattern-library.md) - Complete pattern catalog
- [Back to SKILL.md](../SKILL.md)
