# Repository Pattern

**LAYER: Domain (Interface) / Infrastructure (Implementation)**

El Repository Pattern abstrae el acceso a datos. La interfaz vive en Domain, la implementación en Infrastructure.

## ¿Por qué usarlo?

- Desacopla la lógica de negocio de la tecnología de persistencia
- Facilita testing (puedes usar un repositorio en memoria)
- Permite cambiar la base de datos sin tocar el dominio

## Estructura

```
┌─────────────────────────────────────┐
│  Domain Layer                       │
│  ┌─────────────────────────────┐    │
│  │ IUserRepository (interface) │◄───┼── Contrato
│  │ - save(user)                │    │
│  │ - findById(id)              │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
            ▲ implements
┌─────────────────────────────────────┐
│  Infrastructure Layer               │
│  ┌─────────────────────────────┐    │
│  │ PrismaUserRepository        │    │
│  │ - save(user) { prisma... }  │    │
│  │ - findById(id) { ... }      │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

## Implementación

### 1. Interfaz en Domain

```typescript
/**
 * LAYER: Domain
 * Contains: Repository Interface (Port)
 * Rules: Solo definición, sin implementación
 */
export interface IUserRepository {
  save(user: User): Promise<void>;
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  delete(id: string): Promise<void>;
}
```

### 2. Implementación en Infrastructure

```typescript
/**
 * LAYER: Infrastructure
 * Contains: Prisma Repository Implementation
 * Rules: Implementa puerto del dominio. Usa Prisma.
 */
export class PrismaUserRepository implements IUserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async save(user: User): Promise<void> {
    await this.prisma.user.upsert({
      where: { id: user.id },
      create: {
        id: user.id,
        email: user.email,
        name: user.name
      },
      update: {
        email: user.email,
        name: user.name
      }
    });
  }

  async findById(id: string): Promise<User | null> {
    const data = await this.prisma.user.findUnique({ where: { id } });
    if (!data) return null;
    
    // Mapeo de Prisma model a Domain entity
    return new User(data.id, data.email, data.name);
  }

  async findByEmail(email: string): Promise<User | null> {
    const data = await this.prisma.user.findUnique({ where: { email } });
    if (!data) return null;
    return new User(data.id, data.email, data.name);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.user.delete({ where: { id } });
  }
}
```

### 3. Implementación en memoria para tests

```typescript
/**
 * LAYER: Infrastructure (Test)
 * Contains: In-Memory Repository for testing
 */
export class InMemoryUserRepository implements IUserRepository {
  private users: Map<string, User> = new Map();

  async save(user: User): Promise<void> {
    this.users.set(user.id, user);
  }

  async findById(id: string): Promise<User | null> {
    return this.users.get(id) || null;
  }

  async findByEmail(email: string): Promise<User | null> {
    return Array.from(this.users.values()).find(u => u.email === email) || null;
  }

  async delete(id: string): Promise<void> {
    this.users.delete(id);
  }

  // Helper para tests
  clear(): void {
    this.users.clear();
  }
}
```

## Uso en Application Layer

```typescript
/**
 * LAYER: Application
 */
export class CreateUserUseCase {
  constructor(
    private readonly userRepository: IUserRepository  // <-- Interfaz, no implementación
  ) {}

  async execute(input: CreateUserDTO): Promise<void> {
    const user = new User(
      generateId(),
      input.email,
      input.name
    );
    
    // Uso agnóstico a la tecnología de persistencia
    await this.userRepository.save(user);
  }
}
```

## Reglas de oro

| ✅ Hacer | ❌ Evitar |
|---------|----------|
| Interfaz en Domain | Implementación concreta en Domain |
| Retornar Entities del Domain | Retornar Prisma models/ORM al Application |
| Un repository por Aggregate Root | Un repository por cada tabla |
| Mapear en Infrastructure | Exponer detalles de DB al Application |
| Inyectar interfaz en Use Cases | Importar Prisma en Use Cases |

## Cuándo NO usar Repository Pattern

- Queries de solo lectura complejas (usa Query Service)
- Proyectos con una sola entidad simple
- Cuando el framework ya abstrae bien (ej: Firebase Firestore directo en casos simples)

## Ejemplo completo de estructura

```
src/
├── domain/
│   ├── entities/user.ts
│   └── repositories/user.repository.interface.ts  ◄── Aquí
├── application/
│   └── use-cases/create-user.ts
└── infrastructure/
    └── database/
        └── prisma-user.repository.ts             ◄── Aquí
```
