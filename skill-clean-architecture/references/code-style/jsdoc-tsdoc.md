/**
 * LAYER: Reference / Code Style
 * Contains: JSDoc/TSDoc Documentation Guidelines
 * Purpose: Document when and how to use JSDoc/TSDoc without over-documenting
 */

# JSDoc / TSDoc Documentation

## Filosofía: Documenta el "Por qué", no el "Qué"

> **"El código limpio se documenta solo. Los comentarios explican las decisiones, no la sintaxis."**

TypeScript ya documenta tipos. JSDoc/TSDoc debe usarse para:
- Explicar **intención** y **decisiones de diseño**
- Documentar **invariants** y **contratos**
- Advertir sobre **side effects** o **gotchas**

---

## 1. Cuándo NO documentar (El código habla solo)

### ❌ NO: Lo obvio

```typescript
// ❌ MAL: El código ya es claro
/**
 * Gets the user name
 * @returns The user name
 */
getUserName(): string {
  return this.name;
}

// ❌ MAL: TypeScript ya documenta el tipo
/**
 * @param email The email string
 * @param age The age number
 */
constructor(email: string, age: number) { }
```

### ❌ NO: Comentarios que mienten

```typescript
// ❌ MAL: El comentario dice una cosa, el código otra
/**
 * Calculates discount percentage
 * @returns Discount between 0 and 1
 */
calculateDiscount(): number {
  return 15; // ❌ Siempre retorna 15, no un porcentaje variable
}
```

---

## 2. Cuándo SÍ documentar

### ✅ SÍ: Decisions & Intent

```typescript
/**
 * LAYER: Domain
 * 
 * We use a factory method instead of direct constructor
 * to enforce the business rule that all users must have
 * a verified email before activation.
 */
static create(email: string, name: string): User {
  // ...
}

// ✅ SÍ: Explicar lógica compleja o no obvia
/**
 * Uses optimistic locking to prevent lost updates.
 * Throws ConcurrentModificationError if version mismatch.
 */
async updateBalance(amount: Money): Promise<void> {
  // ...
}
```

### ✅ SÍ: Invariants & Contracts

```typescript
/**
 * LAYER: Domain
 * 
 * Invariant: email must be unique across the system.
 * This is enforced at the application layer before
 * calling this constructor.
 */
constructor(email: Email) {
  this.validateUniqueness(email);
}

// ✅ SÍ: Advertir side effects
/**
 * Sends welcome email to the user.
 * SIDE EFFECT: Calls external email service (async).
 */
async sendWelcomeEmail(): Promise<void> {
  await this.emailService.send(...);
}
```

### ✅ SÍ: Public APIs (Use Cases, Ports)

```typescript
/**
 * LAYER: Application
 * 
 * Orchestrates user registration flow:
 * 1. Validates email uniqueness
 * 2. Creates user entity
 * 3. Persists to repository
 * 4. Sends welcome email (async, non-blocking)
 * 
 * @throws EmailAlreadyExistsError if email is taken
 * @throws WeakPasswordError if password < 8 chars
 */
async execute(input: CreateUserDTO): Promise<User> {
  // ...
}
```

---

## 3. Estructura Mínima de JSDoc

### Para clases públicas:

```typescript
/**
 * LAYER: Application | Domain | Infrastructure | Interface
 * 
 * One-line description of responsibility.
 * 
 * Additional context only if necessary (business rules, design decisions).
 */
```

### Para métodos públicos:

```typescript
/**
 * Short description of what it does.
 * 
 * @param paramName - Description (only if not obvious from type)
 * @returns Description (only if behavior is complex)
 * @throws ErrorType - When/why it throws
 */
```

### Para interfaces (Ports):

```typescript
/**
 * LAYER: Domain | Application
 * 
 * Defines the contract for [specific capability].
 * 
 * Implementations:
 * - Infrastructure: [ImplementationName]
 */
export interface IUserRepository {
  // ...
}
```

---

## 4. TSDoc (Microsoft) - Preferido para TypeScript

TSDoc es un estándar más estricto que JSDoc, diseñado para TypeScript.

### Diferencias clave:

| Feature | JSDoc | TSDoc |
|---------|-------|-------|
| Type annotations | `@param {string} name` | No types (TS ya los tiene) |
| `@returns` | `@returns {User}` | `@returns` sin tipo |
| `@link` | `{@link Class#method}` | `{@link Class.method}` |

### Ejemplo TSDoc:

```typescript
/**
 * LAYER: Application
 * 
 * Creates a new order for the given customer.
 * 
 * @param customerId - Valid customer UUID
 * @param items - Non-empty list of order items
 * @returns The created order with calculated totals
 * @throws CustomerNotFoundError if customer doesn't exist
 * @throws EmptyOrderError if items array is empty
 * 
 * @example
 * ```typescript
 * const order = await useCase.execute({
 *   customerId: 'uuid-123',
 *   items: [{ productId: 'p-1', quantity: 2 }]
 * });
 * ```
 */
async execute(input: CreateOrderDTO): Promise<Order> {
  // ...
}
```

---

## 5. Anti-Patrón: Documentación Excesiva

### ❌ MAL: Carpet bombing de comentarios

```typescript
/**
 * LAYER: Domain
 * 
 * The User class.
 * This class represents a user.
 * Users have properties.
 * 
 * @author John Doe
 * @since 1.0.0
 * @version 2.0.0
 * @deprecated Never
 * @see AnotherClass
 * @todo Nothing
 */
class User {
  /** The id field */
  id: string;
  
  /** The email field */
  email: string;
  
  /** The name field */
  name: string;
  
  /**
   * Gets the id
   * @returns The id
   */
  getId(): string {
    return this.id;
  }
}
```

### ✅ BIEN: Minimal y útil

```typescript
/**
 * LAYER: Domain
 * 
 * Represents a registered user in the system.
 * Email uniqueness is enforced at the application layer.
 */
class User {
  constructor(
    readonly id: UserId,
    readonly email: Email,
    private _name: string
  ) {}
  
  /**
   * Updates the user's display name.
   * Does not affect the email or id.
   */
  updateName(newName: string): void {
    this._name = newName;
  }
}
```

---

## 6. Checklist de Documentación

### Obligatorio:
- [ ] Header `LAYER: X` en cada archivo
- [ ] Descripción de clases públicas (Domain, Application)
- [ ] `@throws` para errores de dominio/documentados
- [ ] Explicar invariants no obvios

### Opcional (solo si aporta valor):
- [ ] `@param` cuando el nombre no es autoexplicativo
- [ ] `@returns` cuando la lógica es compleja
- [ ] `@example` para APIs públicas complejas

### Prohibido:
- [ ] Documentar getters/setters triviales
- [ ] Repetir información del tipo
- [ ] Metadatos innecesarios (@author, @since, @version)
- [ ] Comentarios que pueden mentir (se olvidan actualizar)

---

## 7. Integración con IDE

Con TSDoc bien escrito, obtienes:

```typescript
// Hover sobre el método muestra:
// ========================================
// Creates a new order for the given customer.
//
// @param customerId - Valid customer UUID
// @returns The created order...
// ========================================

const order = await useCase.execute(...)
```

Y autocompletado con descripciones inline.

---

## TL;DR

```typescript
// ❌ NO
/** Gets the name @returns string */
getName(): string { return this.name; }

// ✅ SÍ
/**
 * LAYER: Domain
 * 
 * Returns display name or email if name not set.
 * Used for UI rendering when profile is incomplete.
 */
getDisplayName(): string {
  return this.name || this.email;
}
```

> **"Documenta intención, no implementación."**