/**
 * LAYER: Documentation / Reference
 * Contains: Dependency Injection Pattern - Simple Approach
 * Rules: No frameworks, manual wiring, clear and minimal
 */

# Dependency Injection - Simple Approach (Manual)

## El Problema

Sin DI, creamos dependencias dentro de las clases:

```typescript
// ❌ MAL: Acoplamiento fuerte
class CreateUserUseCase {
  private userRepo = new PrismaUserRepository(); // Acoplado a Prisma
  private emailService = new SendGridService();  // Acoplado a SendGrid
  
  async execute(data) {
    // ...
  }
}
```

## La Solución Simple (Constructor Injection)

```typescript
// ✅ BIEN: Depende de interfaces, no implementaciones

/**
 * LAYER: Application
 */
class CreateUserUseCase {
  constructor(
    private readonly userRepo: IUserRepository,
    private readonly emailService: IEmailService
  ) {}
  
  async execute(data: CreateUserDTO): Promise<User> {
    const user = new User(data.email, data.name);
    await this.userRepo.save(user);
    await this.emailService.sendWelcome(user.email);
    return user;
  }
}
```

## El "Composition Root" (Wiring Manual)

Un solo archivo donde conectamos todo:

```typescript
// src/composition.ts (o index.ts, main.ts, app.ts)
/**
 * LAYER: Infrastructure (Bootstrap)
 * Contains: Dependency wiring and composition
 */

import { PrismaClient } from '@prisma/client';
import { PrismaUserRepository } from './infrastructure/database/prisma-user.repo';
import { SendGridEmailService } from './infrastructure/services/sendgrid.service';
import { CreateUserUseCase } from './application/use-cases/create-user.use-case';
import { UserController } from './interface/http/controllers/user.controller';
import { userRoutes } from './interface/http/routes/user.routes';

// 1. Frameworks & Drivers (singletons)
const prisma = new PrismaClient();

// 2. Repositories
const userRepository = new PrismaUserRepository(prisma);

// 3. External Services
const emailService = new SendGridEmailService();

// 4. Use Cases (injected with their dependencies)
const createUserUseCase = new CreateUserUseCase(userRepository, emailService);
const getUserUseCase = new GetUserUseCase(userRepository);

// 5. Controllers (injected with use cases)
const userController = new UserController(createUserUseCase, getUserUseCase);

// 6. Routes (receive controllers)
export const appRoutes = userRoutes(userController);
```

## ¿Por qué NO usar frameworks de DI?

| Aspecto | Manual | Framework (TSyringe, Inversify, etc.) |
|---------|--------|--------------------------------------|
| **Código** | Explícito, claro | "Mágico", decorators por todos lados |
| **Curva** | Cero aprendizaje | Hay que aprender el framework |
| **Debug** | Fácil seguir el flujo | Stack traces complicados |
| **Bundle** | Sin dependencias extras | +10KB-50KB, más vulnerabilidades |
| **Test** | Mockear es trivial | Necesitas entender el container |

## Testing con DI Manual

```typescript
// test/create-user.use-case.spec.ts

import { CreateUserUseCase } from '../application/use-cases/create-user.use-case';

// Mocks simples - no necesitas librerías de mock
const mockRepo = {
  save: jest.fn(),
  findById: jest.fn()
};

const mockEmail = {
  sendWelcome: jest.fn()
};

test('crea usuario y envía email', async () => {
  const useCase = new CreateUserUseCase(mockRepo, mockEmail);
  
  await useCase.execute({ email: 'test@test.com', name: 'Juan' });
  
  expect(mockRepo.save).toHaveBeenCalled();
  expect(mockEmail.sendWelcome).toHaveBeenCalledWith('test@test.com');
});
```

## Reglas de Oro

1. **Un solo composition root** - Solo un archivo conoce todas las implementaciones concretas
2. **Interfaces en capas internas** - Domain y Application definen los "ports"
3. **Implementaciones en capas externas** - Infrastructure provee los "adapters"
4. **Nunca uses `new` dentro de clases de negocio** - Solo en el composition root
5. **Constructor injection > Property injection** - Más explícito, inmutable

## Casos Especiales

### Factory Functions (cuando necesitas lógica de creación)

```typescript
// Si necesitas condicionales o lógica para crear
function createUserUseCase(): CreateUserUseCase {
  const repo = process.env.NODE_ENV === 'test' 
    ? new InMemoryUserRepository()
    : new PrismaUserRepository(prisma);
    
  return new CreateUserUseCase(repo, emailService);
}
```

### Singletons vs Instancias

```typescript
// Servicios sin estado → singleton
const emailService = new SendGridService();

// Repositorios sin estado → singleton  
const userRepo = new PrismaUserRepository(prisma);

// Use cases sin estado → singleton (usualmente)
const createUserUseCase = new CreateUserUseCase(userRepo, emailService);
```

---

## TL;DR

```typescript
// ❌ NO: Acoplado, difícil de testear
class X { private repo = new PrismaRepo(); }

// ✅ SÍ: Inyectado, testeable, desacoplado
class X { 
  constructor(private repo: IRepo) {} 
}

// Wiring en un solo archivo (composition root)
const x = new X(new PrismaRepo());
```
