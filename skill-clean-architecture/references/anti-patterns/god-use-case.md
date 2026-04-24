/**
 * LAYER: Documentation / Reference
 * Contains: God Use Case Anti-Pattern
 * Purpose: Document what NOT to do with use cases
 */

# Anti-Pattern: God Use Case

## Descripción

Un **God Use Case** es un anti-patrón donde un solo caso de uso maneja múltiples operaciones, violando el Principio de Responsabilidad Única (SRP).

## El Problema

```typescript
// ❌ MAL: God Use Case - hace de todo
/**
 * LAYER: Application
 */
export class UserManagementUseCase {
  constructor(
    private readonly userRepo: IUserRepository,
    private readonly emailService: IEmailService,
    private readonly auditLogger: IAuditLogger,
    private readonly cacheService: ICacheService,
    private readonly notificationService: INotificationService
  ) {}

  async execute(action: string, payload: any): Promise<any> {
    switch (action) {
      case 'create':
        return this.createUser(payload);
      case 'update':
        return this.updateUser(payload);
      case 'delete':
        return this.deleteUser(payload);
      case 'list':
        return this.listUsers(payload);
      case 'changePassword':
        return this.changePassword(payload);
      case 'activate':
        return this.activateUser(payload);
      case 'deactivate':
        return this.deactivateUser(payload);
      case 'assignRole':
        return this.assignRole(payload);
      default:
        throw new Error('Unknown action');
    }
  }

  private async createUser(data: any) {
    const user = new User(/* ... */);
    await this.userRepo.save(user);
    await this.emailService.sendWelcome(user.email);
    await this.auditLogger.log('USER_CREATED', user.id);
    return user;
  }

  private async updateUser(data: any) {
    // 30 líneas más de lógica...
  }

  private async deleteUser(data: any) {
    // 25 líneas más de lógica...
  }

  private async listUsers(filters: any) {
    // 20 líneas más de lógica...
  }

  // ... y 4 métodos más
}
```

## ¿Por qué es malo?

| Problema | Consecuencia |
|----------|--------------|
| **Violación SRP** | Una clase con múltiples razones para cambiar |
| **Difícil de testear** | Tests gigantes, múltiples escenarios en una clase |
| **Alta complejidad ciclomática** | El `switch` crea múltiples caminos de ejecución |
| **Acoplamiento excesivo** | Necesita inyectar dependencias para todas las operaciones |
| **Baja cohesion** | Métodos no relacionados comparten la misma clase |
| **Difícil de mantener** | Cambiar una operación puede romper otras |

## La Solución: Use Cases Específicos

```typescript
// ✅ BIEN: Use cases separados, cada uno con una responsabilidad

// LAYER: Application
export class CreateUserUseCase {
  constructor(
    private readonly userRepo: IUserRepository,
    private readonly emailService: IEmailService
  ) {}

  async execute(input: CreateUserDTO): Promise<UserResponseDTO> {
    const user = new User(/* ... */);
    await this.userRepo.save(user);
    await this.emailService.sendWelcome(user.email);
    return this.toResponse(user);
  }
}

// LAYER: Application
export class UpdateUserUseCase {
  constructor(
    private readonly userRepo: IUserRepository,
    private readonly auditLogger: IAuditLogger
  ) {}

  async execute(input: UpdateUserDTO): Promise<UserResponseDTO> {
    const user = await this.userRepo.findById(input.id);
    user.updateProfile(input.name, input.avatar);
    await this.userRepo.save(user);
    await this.auditLogger.log('USER_UPDATED', user.id);
    return this.toResponse(user);
  }
}

// LAYER: Application
export class DeleteUserUseCase {
  constructor(
    private readonly userRepo: IUserRepository,
    private readonly cacheService: ICacheService
  ) {}

  async execute(userId: string): Promise<void> {
    await this.userRepo.delete(userId);
    await this.cacheService.invalidate(`user:${userId}`);
  }
}

// ... etc
```

## Comparación

| Aspecto | God Use Case | Use Cases Separados |
|---------|--------------|---------------------|
| **Líneas de código** | 200-500+ | 30-50 cada uno |
| **Dependencias** | 6-10 inyectadas | 2-3 inyectadas |
| **Tests** | 1 archivo de 500 líneas | 4 archivos de 50 líneas |
| **Cambio de código** | Alto riesgo | Bajo riesgo |
| **Reusabilidad** | Ninguna | Puedes reusar operaciones individuales |

## Señales de Alerta (Code Smells)

```typescript
// 1. Switch/If-else con strings de acciones
if (action === 'CREATE') { }
else if (action === 'UPDATE') { }

// 2. Parámetros genéricos de tipo "any"
execute(action: string, payload: any): Promise<any>

// 3. Demasiadas dependencias inyectadas (5+)
constructor(dep1, dep2, dep3, dep4, dep5, dep6, dep7)

// 4. Métodos privados que podrían ser use cases
private async processPayment() { }
private async sendNotification() { }

// 5. Comentarios explicando qué hace cada rama
// This handles user registration for premium accounts
case 'premium-register': 
```

## Regla de Oro

> **Si tu use case tiene más de 3 dependencias inyectadas o más de 2 responsabilidades, divídelo.**

## Excepciones Válidas

Hay casos donde agrupar es aceptable:

```typescript
// ✅ OK: Operaciones CRUD simples relacionadas
export class ManageUserProfileUseCase {
  async updateProfile() { }
  async uploadAvatar() { }
  async changePassword() { }
  // Todas relacionadas al "perfil del usuario"
}

// ❌ MAL: Operaciones no relacionadas
export class UserAdminUseCase {
  async createUser() { }      // Creación
  async generateReport() { }  // Reportes (diferente dominio)
  async backupData() { }      // Infraestructura
}
```

## Testing: Antes vs Después

### God Use Case (Difícil)
```typescript
test('UserManagementUseCase', () => {
  // Setup de 10 mocks
  const useCase = new UserManagementUseCase(mock1, mock2, ...mock10);
  
  // Test para 'create'
  await useCase.execute('create', data);
  
  // Test para 'update' - reusa los mismos mocks, es confuso
  await useCase.execute('update', data);
  
  // 200 líneas de tests...
});
```

### Use Cases Separados (Fácil)
```typescript
test('CreateUserUseCase', () => {
  const useCase = new CreateUserUseCase(mockRepo, mockEmail);
  // Test enfocado, 20 líneas
});

test('UpdateUserUseCase', () => {
  const useCase = new UpdateUserUseCase(mockRepo, mockLogger);
  // Test enfocado, 20 líneas
});
```

## TL;DR

```typescript
// ❌ NO: God Use Case
class UserUseCase {
  execute(action: string, data: any) {
    switch(action) { /* 10 cases */ }
  }
}

// ✅ SÍ: Use cases específicos
class CreateUserUseCase { }
class UpdateUserUseCase { }
class DeleteUserUseCase { }
```
