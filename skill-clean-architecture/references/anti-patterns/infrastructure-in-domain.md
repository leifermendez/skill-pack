/**
 * LAYER: Documentation / Reference
 * Contains: Anti-Pattern - Infrastructure in Domain
 * Purpose: Show what NOT to do
 */

# Anti-Pattern: Infrastructure en el Domain

## El Problema

Llevar dependencias de infraestructura (frameworks, ORMs, APIs externas) a la capa de dominio rompe la regla fundamental de Clean Architecture: **las capas internas no deben conocer nada del exterior**.

## ❌ MAL: Domain con dependencias de Infrastructure

```typescript
// src/domain/entities/user.ts
/**
 * LAYER: Domain  <-- ¡Esto es mentira! Tiene infraestructura
 */

import { v4 as uuidv4 } from 'uuid';  // ❌ Librería externa
import bcrypt from 'bcrypt';          // ❌ Librería externa
import { PrismaClient } from '@prisma/client';  // ❌ ORM!

export class User {
  private prisma = new PrismaClient();  // ❌ Base de datos en Domain!
  
  constructor(
    public email: string,
    public password: string
  ) {
    this.id = uuidv4();  // ❌ Generación de ID externa
    this.password = bcrypt.hashSync(password, 10);  // ❌ Encriptación en Domain
  }

  async save() {  // ❌ Persistencia en la entidad
    await this.prisma.user.create({
      data: { email: this.email, password: this.password }
    });
  }
}
```

**Problemas:**
- No se puede testear sin base de datos real
- Acoplado a Prisma (no se puede cambiar a TypeORM/Mongoose)
- Acoplado a bcrypt (no se puede cambiar de algoritmo)
- Acoplado a UUID (no se puede usar ULID, nanoid, etc.)

---

## ✅ BIEN: Domain puro, Infrastructure separada

### Domain (solo reglas de negocio puras)

```typescript
// src/domain/entities/user.ts
/**
 * LAYER: Domain
 * Contains: User Entity
 * Rules: No external dependencies. Pure business logic only.
 */

export class User {
  constructor(
    public readonly id: string,        // <-- Recibe el ID, no lo genera
    public readonly email: string,
    public hashedPassword: string     // <-- Ya viene hasheado
  ) {
    this.validateEmail(email);
  }

  private validateEmail(email: string): void {
    if (!email.includes('@')) {
      throw new Error('Email inválido');
    }
  }

  // Lógica de negocio pura, no dependencias externas
  canAccess(resourceOwnerId: string): boolean {
    return this.id === resourceOwnerId;
  }
}
```

### Ports (interfaces definidas en Application)

```typescript
// src/application/ports/id-generator.port.ts
/**
 * LAYER: Application
 * Contains: ID Generator Port
 */
export interface IIdGenerator {
  generate(): string;
}

// src/application/ports/password-hasher.port.ts
/**
 * LAYER: Application
 */
export interface IPasswordHasher {
  hash(password: string): string;
  compare(password: string, hash: string): boolean;
}
```

### Infrastructure (implementaciones concretas)

```typescript
// src/infrastructure/services/uuid-generator.service.ts
/**
 * LAYER: Infrastructure
 * Contains: UUID Generator Implementation
 */
import { v4 as uuidv4 } from 'uuid';
import { IIdGenerator } from '../../application/ports/id-generator.port';

export class UuidGenerator implements IIdGenerator {
  generate(): string {
    return uuidv4();
  }
}

// src/infrastructure/services/bcrypt-hasher.service.ts
/**
 * LAYER: Infrastructure
 */
import bcrypt from 'bcrypt';
import { IPasswordHasher } from '../../application/ports/password-hasher.port';

export class BcryptHasher implements IPasswordHasher {
  hash(password: string): string {
    return bcrypt.hashSync(password, 10);
  }

  compare(password: string, hash: string): boolean {
    return bcrypt.compareSync(password, hash);
  }
}

// src/infrastructure/database/prisma-user.repo.ts
/**
 * LAYER: Infrastructure
 */
import { PrismaClient } from '@prisma/client';
import { IUserRepository } from '../../domain/repositories/user.repository.interface';

export class PrismaUserRepository implements IUserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async save(user: User): Promise<void> {
    await this.prisma.user.create({
      data: {
        id: user.id,
        email: user.email,
        password: user.hashedPassword
      }
    });
  }
}
```

### Application (orquestación)

```typescript
// src/application/use-cases/create-user.use-case.ts
/**
 * LAYER: Application
 */
export class CreateUserUseCase {
  constructor(
    private readonly idGenerator: IIdGenerator,      // <-- Interfaz
    private readonly passwordHasher: IPasswordHasher, // <-- Interfaz
    private readonly userRepository: IUserRepository    // <-- Interfaz
  ) {}

  async execute(input: CreateUserDTO): Promise<User> {
    // 1. Generar ID (a través de puerto)
    const id = this.idGenerator.generate();
    
    // 2. Hashear password (a través de puerto)
    const hashedPassword = this.passwordHasher.hash(input.password);
    
    // 3. Crear entidad pura
    const user = new User(id, input.email, hashedPassword);
    
    // 4. Persistir (a través de puerto)
    await this.userRepository.save(user);
    
    return user;
  }
}
```

---

## Otras formas comunes de violar esta regla

### ❌ Usar `Date.now()` o `new Date()` en Domain
```typescript
// MAL
class Order {
  createdAt = new Date();  // Dependencia del sistema/host
}

// BIEN
class Order {
  constructor(public readonly createdAt: Date) {}  // Inyectado
}
```

### ❌ Usar `fetch`, `axios`, o `http` en Domain
```typescript
// MAL
class PaymentService {
  async charge() {
    await fetch('https://api.stripe.com/...');  // HTTP en Domain!
  }
}

// BIEN
// En Application: define IPaymentGateway
// En Infrastructure: implementa con Stripe SDK
```

### ❌ Leer variables de entorno en Domain
```typescript
// MAL
class User {
  static MAX_LOGIN_ATTEMPTS = process.env.MAX_ATTEMPTS;  // ❌

// BIEN
// Pasar por constructor o leer en Infrastructure/Application
class User {
  constructor(private readonly maxAttempts: number) {}
}
```

### ❌ Usar `console.log`, winston, pino en Domain
```typescript
// MAL
class User {
  save() {
    console.log('Guardando usuario');  // Side effect en Domain
    // ...
  }
}

// BIEN
// En Application o Infrastructure
```

### ❌ Usar clase `EventEmitter` de Node en Domain
```typescript
// MAL
import { EventEmitter } from 'events';  // ❌ Node.js específico

class User extends EventEmitter {
  constructor() {
    super();
  }
}

// BIEN
// Eventos de dominio como objetos planos
class UserCreatedEvent {
  constructor(public readonly userId: string) {}
}
```

---

## Regla de Oro

> **Si necesitas hacer `import` de algo que no sea:**
> - El propio lenguaje (std lib)
> - Otras clases de tu propio dominio
> 
> **Estás en la capa equivocada.**

## Checklist para detectar este anti-patrón

- [ ] ¿Hay imports de `uuid`, `crypto`, `bcrypt` en `src/domain/`?
- [ ] ¿Hay imports de ORMs (Prisma, TypeORM, Mongoose) en `src/domain/`?
- [ ] ¿Hay imports de HTTP clients en `src/domain/`?
- [ ] ¿Hay imports de librerías de terceros en `src/domain/`?
- [ ] ¿Las entidades tienen métodos `save()`, `update()`, `delete()`?
- [ ] ¿Se usa `new Date()`, `Date.now()`, `Math.random()` en entidades?

Si marcaste alguna ✅, necesitas refactorizar.