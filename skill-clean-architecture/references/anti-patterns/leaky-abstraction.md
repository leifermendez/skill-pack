/**
 * LAYER: Reference Documentation
 * Contains: Leaky Abstraction Anti-Pattern
 * Rules: Document what NOT to do and how to fix it
 */

# Anti-Pattern: Leaky Abstraction

## ¿Qué es?

Una **Leaky Abstraction** ocurre cuando los detalles de implementación de una capa interna "traspasan" hacia capas externas, rompiendo la separación de responsabilidades.

> "La abstracción es imperfecta cuando los detalles de lo que está debajo se filtran hacia arriba"

## Ejemplo Clásico: ORM en el Dominio

### ❌ MAL: Entidad con Prisma

```typescript
// ❌ LAYER: Domain (contaminada)
import { PrismaClient } from '@prisma/client'; // ¡Framework en Domain!

@Entity() // ¡Decorator de ORM en Domain!
export class User {
  @PrimaryKey() // ¡Detalle de persistencia!
  id: string;

  @Column() // ¡Detalle de persistencia!
  email: string;

  constructor(data: Prisma.UserCreateInput) { // ¡Tipo de Prisma!
    this.id = generateId();
    this.email = data.email;
  }

  async save() { // ¡Método de persistencia en entidad!
    const prisma = new PrismaClient();
    await prisma.user.create({ data: this });
  }
}
```

### ✅ BIEN: Entidad pura + Repositorio

```typescript
// ✅ LAYER: Domain (pura)
export class User {
  constructor(
    public readonly id: string,
    public readonly email: string,
    public readonly name: string
  ) {
    if (!email.includes('@')) {
      throw new Error('Invalid email format');
    }
  }

  // Lógica de negocio, NO persistencia
  updateName(newName: string): User {
    return new User(this.id, this.email, newName);
  }
}
```

```typescript
// ✅ LAYER: Infrastructure
export class PrismaUserRepository implements IUserRepository {
  constructor(private prisma: PrismaClient) {}
  
  async save(user: User): Promise<void> {
    await this.prisma.user.create({
      data: {
        id: user.id,
        email: user.email,
        name: user.name
      }
    });
  }
}
```

## Ejemplo: Retornando Modelos de ORM

### ❌ MAL: Use Case retorna Prisma Model

```typescript
// ❌ LAYER: Application
export class GetUserUseCase {
  constructor(private repo: IUserRepository) {}
  
  async execute(id: string) {
    // Retorna Prisma model (con campos internos como createdAt, updatedAt, etc.)
    return await this.prisma.user.findUnique({ where: { id } });
    // ^^^ El controller ahora depende de la estructura de Prisma
  }
}
```

```typescript
// ❌ LAYER: Interface (contaminada)
app.get('/users/:id', async (req, res) => {
  const user = await useCase.execute(req.params.id);
  
  // Accediendo a campos que podrían cambiar si cambiamos de ORM
  res.json({
    id: user.id,
    email: user.email,
    internalId: user.prismaInternalId, // ¡Filtrado!
    dbVersion: user._v // ¡Metadato de DB expuesto!
  });
});
```

### ✅ BIEN: DTOs agnósticos

```typescript
// ✅ LAYER: Application
export interface UserResponseDTO {
  id: string;
  email: string;
  name: string;
}

export class GetUserUseCase {
  constructor(private repo: IUserRepository) {}
  
  async execute(id: string): Promise<UserResponseDTO | null> {
    const user = await this.repo.findById(id);
    if (!user) return null;
    
    // Mapeo explícito a DTO
    return {
      id: user.id,
      email: user.email,
      name: user.name
    };
  }
}
```

## Ejemplo: Errores HTTP en Use Cases

### ❌ MAL: Use Case conoce HTTP

```typescript
// ❌ LAYER: Application
export class CreateUserUseCase {
  async execute(data: CreateUserDTO) {
    if (await this.repo.findByEmail(data.email)) {
      throw new Error('409 Conflict'); // ¡Código HTTP en Application!
    }
    
    if (!data.password || data.password.length < 6) {
      throw new Error('400 Bad Request: Password too short'); // ¡HTTP en lógica!
    }
  }
}
```

### ✅ BIEN: Errores de dominio

```typescript
// ✅ LAYER: Domain
export class EmailAlreadyExistsError extends Error {
  constructor(email: string) {
    super(`Email ${email} already registered`);
    this.name = 'EmailAlreadyExistsError';
  }
}

export class WeakPasswordError extends Error {
  constructor() {
    super('Password must be at least 6 characters');
    this.name = 'WeakPasswordError';
  }
}
```

```typescript
// ✅ LAYER: Application
export class CreateUserUseCase {
  async execute(data: CreateUserDTO) {
    if (await this.repo.findByEmail(data.email)) {
      throw new EmailAlreadyExistsError(data.email); // Error de dominio
    }
    // ...
  }
}
```

```typescript
// ✅ LAYER: Interface (aquí sí usamos HTTP)
app.post('/users', async (req, res, next) => {
  try {
    const result = await useCase.execute(req.body);
    res.status(201).json(result);
  } catch (error) {
    // Mapeo de errores de dominio a HTTP
    if (error instanceof EmailAlreadyExistsError) {
      return res.status(409).json({ error: error.message });
    }
    if (error instanceof WeakPasswordError) {
      return res.status(400).json({ error: error.message });
    }
    next(error);
  }
});
```

## Señales de Alarma (Code Smells)

| Señal | Problema |
|-------|----------|
| `import { Prisma/SQL/Redis } from` en Domain | Framework en capa interna |
| Decoradores de ORM en entidades | Acoplamiento a persistencia |
| Tipos de ORM en firmas de métodos | Dependencia de implementación |
| Códigos HTTP en Application | Capa de aplicación conoce transporte |
| Strings de queries SQL en Use Cases | Fuga de detalles de BD |
| Headers/cookies en Application | Detalles HTTP traspasados |

## Cómo Detectarlo

```bash
# Busca imports de frameworks en Domain
grep -r "prisma\|mongoose\|typeorm" src/domain/

# Busca códigos HTTP en Application
grep -r "400\|404\|409\|500" src/application/

# Busca decoradores de ORM
grep -r "@Entity\|@Column\|@Table" src/domain/
```

## Solución: La Regla de Importación

```typescript
// Domain solo puede importar:
✅ Módulos nativos (fs, path)
✅ Otras clases de Domain
❌ Frameworks (Express, Prisma, Mongoose)
❌ Application, Infrastructure, Interface

// Application solo puede importar:
✅ Domain
❌ Infrastructure (salvo interfaces)
❌ Interface

// Infrastructure sí puede importar:
✅ Todo (es la capa más externa)
```

## Resumen

| ✅ Abstracción Sana | ❌ Leaky Abstraction |
|---------------------|----------------------|
| Domain: POJOs simples | Domain: Clases con decorators de ORM |
| Repository interface define métodos | Repository interface expone QueryBuilder |
| Use Case lanza errores de dominio | Use Case lanza "404 Not Found" |
| DTOs planos y predecibles | DTOs heredan de Prisma Model |
| Infrastructure hace el mapeo | Mapeo disperso en todas las capas |

> **"Si cambiar de PostgreSQL a MongoDB requiere tocar Domain o Application, tienes una leaky abstraction."**