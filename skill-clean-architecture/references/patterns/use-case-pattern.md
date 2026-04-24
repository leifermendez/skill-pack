/**
 * LAYER: Reference Documentation
 * Contains: Use Case Pattern Guide
 * Purpose: Explain the use case pattern for Clean Architecture
 */

# Use Case Pattern

## ¿Qué es un Use Case?

Un **Use Case** (Caso de Uso) es una clase que orquesta una operación de negocio específica. No contiene lógica de negocio, solo **coordina** entidades del dominio y servicios externos para lograr un objetivo.

## Características Esenciales

- **Una responsabilidad**: Un use case = una operación (CrearUsuario, EnviarEmail, ProcesarPago)
- **Sin lógica de negocio**: Solo orquesta, las reglas están en el Domain
- **Inmutable**: Recibe todo por constructor (inyección de dependencias)
- **DTOs de entrada/salida**: No expone entidades del dominio

## Estructura Básica

```
src/application/use-cases/
├── crear-usuario.use-case.ts
├── actualizar-perfil.use-case.ts
└── enviar-notificacion.use-case.ts
```

## Ejemplo Práctico

### DTOs (Input/Output)

```typescript
// LAYER: Application
// Contains: Input DTO
export interface CrearUsuarioInput {
  email: string;
  nombre: string;
  password: string;
}

// LAYER: Application  
// Contains: Output DTO
export interface CrearUsuarioOutput {
  id: string;
  email: string;
  nombre: string;
  creadoEn: Date;
}
```

### Use Case Implementation

```typescript
/**
 * LAYER: Application
 * Contains: Create User Use Case
 * Rules: Orchestrates domain. Depends only on domain. No frameworks.
 */

import { User } from '../../domain/entities/user.entity';
import { IUserRepository } from '../../domain/repositories/user.repository.interface';
import { IIdGenerator } from '../ports/id-generator.port';
import { IEmailService } from '../ports/email-service.port';
import { CrearUsuarioInput, CrearUsuarioOutput } from '../dtos/usuario.dto';

export class CrearUsuarioUseCase {
  constructor(
    private readonly userRepository: IUserRepository,
    private readonly idGenerator: IIdGenerator,
    private readonly emailService: IEmailService
  ) {}

  async execute(input: CrearUsuarioInput): Promise<CrearUsuarioOutput> {
    // 1. Validar input (puede usar un validator simple)
    if (!input.email || !input.nombre) {
      throw new Error('Email y nombre son requeridos');
    }

    // 2. Verificar reglas de negocio (a través del dominio)
    const existingUser = await this.userRepository.findByEmail(input.email);
    if (existingUser) {
      throw new Error('Email ya registrado');
    }

    // 3. Crear entidad de dominio (aquí está la lógica de negocio)
    const user = new User(
      this.idGenerator.generate(),
      input.email,
      input.nombre,
      input.password
    );

    // 4. Persistir
    await this.userRepository.save(user);

    // 5. Acciones secundarias (eventos, notificaciones)
    await this.emailService.sendWelcomeEmail(user.email, user.nombre);

    // 6. Retornar DTO (nunca la entidad directamente)
    return {
      id: user.id,
      email: user.email,
      nombre: user.nombre,
      creadoEn: user.creadoEn
    };
  }
}
```

## Reglas del Use Case

| ✅ DO | ❌ DON'T |
|-------|----------|
| Orquestar pasos de la operación | Contener lógica de negocio compleja |
| Recibir interfaces (puertos) por constructor | Instanciar dependencias con `new` dentro |
| Usar DTOs para entrada y salida | Exponer entidades del dominio al exterior |
| Manejar transacciones | Acceder a la base de datos directamente |
| Lanzar errores de dominio | Retornar HTTP codes o responses |

## Testing

```typescript
describe('CrearUsuarioUseCase', () => {
  it('debe crear un usuario válido', async () => {
    // Arrange
    const mockRepo = {
      findByEmail: jest.fn().mockResolvedValue(null),
      save: jest.fn().mockResolvedValue(undefined)
    };
    const mockIdGen = { generate: jest.fn().mockReturnValue('uuid-123') };
    const mockEmail = { sendWelcomeEmail: jest.fn() };
    
    const useCase = new CrearUsuarioUseCase(mockRepo, mockIdGen, mockEmail);
    
    // Act
    const result = await useCase.execute({
      email: 'test@test.com',
      nombre: 'Juan',
      password: '123456'
    });
    
    // Assert
    expect(result.id).toBe('uuid-123');
    expect(mockRepo.save).toHaveBeenCalledTimes(1);
    expect(mockEmail.sendWelcomeEmail).toHaveBeenCalledWith('test@test.com', 'Juan');
  });
});
```

## Cuándo NO usar un Use Case

- Si la operación es solo un CRUD simple sin reglas de negocio
- Si solo consulta datos (usar Query Service o Repository directo)
- Si la lógica cabe en una entidad de dominio

## Anti-Patrón: God Use Case

```typescript
// ❌ MAL: Use case que hace todo
export class GestionUsuariosUseCase {
  async execute(accion: string, data: any) {
    if (accion === 'crear') { /* ... */ }
    if (accion === 'actualizar') { /* ... */ }
    if (accion === 'eliminar') { /* ... */ }
    if (accion === 'listar') { /* ... */ }
    // ¡Esto es un controlador disfrazado!
  }
}
```

```typescript
// ✅ BIEN: Use cases separados
export class CrearUsuarioUseCase { }
export class ActualizarUsuarioUseCase { }
export class EliminarUsuarioUseCase { }
export class ListarUsuariosUseCase { }
```

## Resumen

> **Un Use Case es un "script" que coordina objetos del dominio para lograr un objetivo de usuario específico.**