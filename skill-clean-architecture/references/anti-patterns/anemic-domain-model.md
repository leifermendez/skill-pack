/**
 * LAYER: Reference / Anti-Pattern Documentation
 * Contains: Anemic Domain Model Anti-Pattern
 * Purpose: Show what NOT to do - logic should be in entities, not services
 */

# Anti-Pattern: Anemic Domain Model (Modelo de Dominio Anémico)

## ¿Qué es?

Un **Modelo de Dominio Anémico** es cuando tus entidades son solo estructuras de datos (DTOs) sin comportamiento. Toda la lógica de negocio vive en "Services" separados.

```typescript
// ❌ MAL: Entidad anémica - solo datos, sin comportamiento
export class User {
  id: string;
  email: string;
  name: string;
  status: string;
  // Solo getters/setters o propiedades públicas
}

// ❌ MAL: Toda la lógica está en un "Service" procedural
export class UserService {
  async activateUser(userId: string) {
    const user = await this.repo.findById(userId);
    
    // La lógica de negocio está AQUÍ, no en la entidad
    if (user.status === 'banned') {
      throw new Error('Usuario baneado no puede activarse');
    }
    if (user.status === 'active') {
      throw new Error('Usuario ya está activo');
    }
    
    user.status = 'active'; // Mutación directa
    await this.repo.save(user);
  }
}
```

## El Problema

| Síntoma | Consecuencia |
|---------|-------------|
| Entidades con solo propiedades | Incapacidad de proteger invariants |
| Múltiples services con lógica repetida | Código duplicado, inconsistencias |
| Lógica de negocio dispersa | Difícil de encontrar y mantener |
| Mutación libre de entidades | Estado inconsistente, bugs difíciles de trackear |

## La Solución: Rich Domain Model

```typescript
// ✅ BIEN: Entidad con comportamiento (Rich Model)
export class User {
  private constructor(
    public readonly id: string,
    private _email: string,
    private _name: string,
    private _status: UserStatus
  ) {}
  
  // Factory method con validación
  static create(id: string, email: string, name: string): User {
    if (!email.includes('@')) {
      throw new Error('Email inválido');
    }
    if (name.length < 2) {
      throw new Error('Nombre debe tener al menos 2 caracteres');
    }
    
    return new User(id, email, name, UserStatus.PENDING);
  }
  
  // Comportamiento encapsulado - la entidad protege sus invariants
  activate(): void {
    if (this._status === UserStatus.BANNED) {
      throw new Error('Usuario baneado no puede activarse');
    }
    if (this._status === UserStatus.ACTIVE) {
      throw new Error('Usuario ya está activo');
    }
    
    this._status = UserStatus.ACTIVE;
  }
  
  ban(reason: string): void {
    if (this._status === UserStatus.BANNED) {
      throw new Error('Usuario ya está baneado');
    }
    
    this._status = UserStatus.BANNED;
    this._banReason = reason;
  }
  
  updateEmail(newEmail: string): void {
    if (!newEmail.includes('@')) {
      throw new Error('Email inválido');
    }
    this._email = newEmail;
  }
  
  // Getters para acceso controlado
  get email(): string { return this._email; }
  get name(): string { return this._name; }
  get status(): UserStatus { return this._status; }
  isActive(): boolean { return this._status === UserStatus.ACTIVE; }
}

// ✅ BIEN: Use Case simple que ORQUESTA (no contiene lógica)
export class ActivateUserUseCase {
  constructor(private readonly userRepo: IUserRepository) {}
  
  async execute(userId: string): Promise<void> {
    const user = await this.userRepo.findById(userId);
    if (!user) throw new Error('Usuario no encontrado');
    
    // La lógica está en la entidad - el use case solo orquesta
    user.activate();
    
    await this.userRepo.save(user);
  }
}
```

## Comparación Rápida

| Anemic Model | Rich Model |
|--------------|-----------|
| `user.status = 'active'` (cualquiera puede) | `user.activate()` (con reglas) |
| Validación en 5 lugares diferentes | Validación en el constructor/factory |
| Service sabe demasiado | Entidad se protege a sí misma |
| Fácil de crear estado inválido | Imposible crear estado inválido |

## Regla de Oro

> **Si una operación involucra el estado de una entidad, esa operación debe ser un MÉTODO de la entidad, no una función en un Service externo.**

## Excepciones (cuándo sí es válido)

Algunos casos donde un Service de Dominio tiene sentido:

```typescript
// ✅ BIEN: Operación que involucra MÚLTIPLES aggregates
export class TransferService {
  async transfer(
    fromAccountId: string,
    toAccountId: string,
    amount: Money
  ): Promise<void> {
    // Necesita coordinar DOS entidades
    const from = await this.accountRepo.findById(fromAccountId);
    const to = await this.accountRepo.findById(toAccountId);
    
    from.debit(amount);  // Lógica en entidad
    to.credit(amount);   // Lógica en entidad
    
    await this.accountRepo.save(from);
    await this.accountRepo.save(to);
  }
}
```

## Checklist Anti-Anemic

- [ ] ¿Las entidades tienen métodos de negocio?
- [ ] ¿Los setters públicos están justificados?
- [ ] ¿La validación está en el constructor/factory?
- [ ] ¿Los use cases solo orquestan sin lógica de negocio?
- [ ] ¿Las reglas de negocio son testeables sin el Service?

## TL;DR

```typescript
// ❌ NO: Entidad es un bolsa de datos
class User { name: string; status: string; }

// ✅ SÍ: Entidad protege sus invariants
class User { 
  private _status: Status;
  activate() { /* reglas aquí */ }
}
```
