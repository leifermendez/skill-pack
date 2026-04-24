/**
 * LAYER: Reference Documentation
 * Contains: Type Safety Best Practices
 * Purpose: Enforce strict typing and type-safe patterns
 */

# Type Safe - Reglas de Seguridad de Tipos

## Filosofía

> **"El compilador es tu primer test. Aprovechalo al máximo."**

TypeScript (o cualquier lenguaje tipado) debe usarse con `strict` mode activado. Los tipos son documentación ejecutable que previene errores en runtime.

---

## 1. Strict Mode (Obligatorio)

### ❌ NO: TypeScript relajado
```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": false,           // ❌ NUNCA
    "noImplicitAny": false,  // ❌ Implicit any
    "strictNullChecks": false // ❌ Null puede ser cualquier cosa
  }
}
```

### ✅ SÍ: Strict mode completo
```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,           // ✅ Activa todo
    "noImplicitAny": true,    // ✅ Cualquier cosa debe ser tipada
    "strictNullChecks": true, // ✅ null/undefined explícitos
    "noImplicitReturns": true, // ✅ Todos los caminos retornan
    "noFallthroughCasesInSwitch": true, // ✅ Switch cases completos
    "exactOptionalPropertyTypes": true   // ✅ undefined !== no existe
  }
}
```

---

## 2. No `any` - Nunca

### ❌ MAL: Abuso de any
```typescript
// LAYER: Application
async function processData(data: any): Promise<any> {
  const result = await fetch('/api', { body: JSON.stringify(data) });
  return await result.json(); // any inferido
}

// Uso - cero seguridad
const user = await processData({}); 
console.log(user.nmae); // ❌ Error en runtime, no en compile time
```

### ✅ BIEN: Tipos explícitos
```typescript
// LAYER: Domain
interface User {
  id: string;
  email: string;
  name: string;
}

// LAYER: Application
interface CreateUserInput {
  email: string;
  name: string;
}

interface CreateUserOutput {
  user: User;
  createdAt: Date;
}

async function createUser(input: CreateUserInput): Promise<CreateUserOutput> {
  // Seguridad completa: el compilador verifica todo
  const response = await fetch('/api/users', {
    method: 'POST',
    body: JSON.stringify(input)
  });
  
  const data: CreateUserOutput = await response.json();
  return data;
}

// Uso - seguro
const result = await createUser({ email: 'test@test.com', name: 'Juan' });
console.log(result.user.name); // ✅ Seguro
console.log(result.user.nmae); // ❌ Error de compilación!
```

---

## 3. Unknown sobre Any

Cuando no sabes el tipo, usa `unknown` en lugar de `any`.

### ❌ MAL: Any sin verificación
```typescript
function parseJson(json: string): any {  // ❌ Any peligroso
  return JSON.parse(json);
}

const data = parseJson('{"email": "test@test.com"}');
sendEmail(data.emial); // ❌ Error en runtime
```

### ✅ BIEN: Unknown + type guards
```typescript
// LAYER: Infrastructure
function parseJson(json: string): unknown {
  return JSON.parse(json);
}

// Type guard
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'email' in obj &&
    typeof (obj as User).email === 'string'
  );
}

// Uso seguro
const data = parseJson('{"email": "test@test.com"}');

if (isUser(data)) {
  // Dentro de este bloque, data es User
  console.log(data.email); // ✅ Seguro
} else {
  throw new Error('Invalid user data');
}

// O con Zod (recomendado)
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string()
});

const data = parseJson(jsonString);
const user = UserSchema.parse(data); // ✅ Lanza si no cumple el schema
```

---

## 4. Branded Types (Tipos Nominales)

TypeScript tiene tipos estructurales. Para diferenciar tipos con la misma estructura:

### ❌ MAL: String común
```typescript
type UserId = string;
type OrderId = string;

function getUser(id: UserId) { }
function getOrder(id: OrderId) { }

const userId: UserId = '123';
getOrder(userId); // ❌ No hay error, aunque semanticamente incorrecto
```

### ✅ BIEN: Branded types
```typescript
// LAYER: Domain
type Brand<K, T> = K & { __brand: T };

type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;

// Factory functions que crean branded types
function createUserId(id: string): UserId {
  return id as UserId;
}

function createOrderId(id: string): OrderId {
  return id as OrderId;
}

// Uso
const userId = createUserId('123');
const orderId = createOrderId('456');

getUser(userId);     // ✅ OK
getUser(orderId);    // ❌ Error de compilación!
getOrder(orderId);   // ✅ OK
getOrder(userId);    // ❌ Error de compilación!
```

---

## 5. Null Safety

### ❌ MAL: Asumir que existe
```typescript
// LAYER: Infrastructure
async function findUser(id: string): Promise<User> {
  const user = await prisma.user.findUnique({ where: { id } });
  return user; // ❌ Puede ser null!
}

// Uso
const user = await findUser('123');
console.log(user.email); // ❌ Runtime error si user es null
```

### ✅ BIEN: Null explícito
```typescript
// LAYER: Domain
// Retorna null explícitamente
async function findUser(id: string): Promise<User | null> {
  const user = await prisma.user.findUnique({ where: { id } });
  return user; // ✅ null es un valor válido y documentado
}

// Uso seguro
const user = await findUser('123');

// Opción 1: Early return
if (!user) {
  throw new Error('User not found');
}
console.log(user.email); // ✅ Seguro después del check

// Opción 2: Optional chaining
console.log(user?.email); // ✅ string | undefined

// Opción 3: Nullish coalescing
const email = user?.email ?? 'unknown'; // ✅ Siempre string
```

---

## 6. Exhaustive Switch / Pattern Matching

### ❌ MAL: Switch incompleto
```typescript
type Status = 'pending' | 'active' | 'inactive';

function getStatusColor(status: Status): string {
  switch (status) {
    case 'pending':
      return 'yellow';
    case 'active':
      return 'green';
    // ❌ Falta 'inactive'!
  }
}
```

### ✅ BIEN: Exhaustive check
```typescript
// Opción 1: Default que nunca debería pasar
function getStatusColor(status: Status): string {
  switch (status) {
    case 'pending':
      return 'yellow';
    case 'active':
      return 'green';
    case 'inactive':
      return 'gray';
    default:
      // TypeScript sabe que esto nunca pasa si el switch es exhaustivo
      const _exhaustiveCheck: never = status;
      throw new Error(`Unhandled status: ${_exhaustiveCheck}`);
  }
}

// Opción 2: Record/map (más declarativo)
const statusColors: Record<Status, string> = {
  pending: 'yellow',
  active: 'green',
  inactive: 'gray'
};

// TypeScript fuerza que todas las keys de Status estén presentes
const color = statusColors[status]; // ✅ Siempre definido
```

---

## 7. DTOs vs Entities (No confundir)

### ❌ MAL: Mismo tipo para todo
```typescript
// Usando la misma interfaz para DB, API y Dominio
interface User {
  id: string;
  email: string;
  passwordHash: string;  // ❌ Expuesto en API!
  internalNotes: string; // ❌ No debe salir al cliente
}
```

### ✅ BIEN: Tipos separados por capa
```typescript
// LAYER: Domain - Entidad pura
interface User {
  id: UserId;
  email: Email;  // Value object
  password: PasswordHash;
  createdAt: Date;
}

// LAYER: Infrastructure - Prisma model
interface UserPrismaModel {
  id: string;
  email: string;
  password_hash: string;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;  // Campo interno de DB
  version: number;          // Optimistic locking
}

// LAYER: Application - Input DTO
interface CreateUserDTO {
  email: string;
  password: string;  // Plain text, validado luego
  name: string;
}

// LAYER: Application - Output DTO
interface UserResponseDTO {
  id: string;
  email: string;
  name: string;
  createdAt: string;  // ISO string para JSON
  // ❌ No password, no internal notes, no deleted_at
}

// Mappers explícitos en Infrastructure
function toDomain(model: UserPrismaModel): User {
  return {
    id: createUserId(model.id),
    email: createEmail(model.email),
    password: createPasswordHash(model.password_hash),
    createdAt: model.created_at
  };
}

function toResponseDTO(user: User): UserResponseDTO {
  return {
    id: user.id,
    email: user.email.toString(),
    name: user.name,
    createdAt: user.createdAt.toISOString()
  };
}
```

---

## 8. Evitar Type Assertions (as)

### ❌ MAL: Forzar tipos
```typescript
const element = document.getElementById('app') as HTMLElement; // ❌ Podría ser null
element.innerHTML = 'Hello'; // ❌ Runtime error si no existe
```

### ✅ BIEN: Verificación explícita
```typescript
const element = document.getElementById('app');

if (!element) {
  throw new Error('Element #app not found');
}

// TypeScript ahora sabe que element no es null
element.innerHTML = 'Hello'; // ✅ Seguro
```

---

## 9. Function Return Types Explícitos

### ❌ MAL: Inferencia en funciones públicas
```typescript
// LAYER: Application
class UserService {
  // Retorna qué? Promise<what>?
  async createUser(data) {
    // ...
  }
}
```

### ✅ BIEN: Tipos explícitos en APIs públicas
```typescript
// LAYER: Application
interface CreateUserResult {
  user: User;
  success: boolean;
  errors?: ValidationError[];
}

class UserService {
  async createUser(data: CreateUserDTO): Promise<CreateUserResult> {
    // TypeScript verifica que retornamos exactamente esto
    return {
      user: createdUser,
      success: true
    };
  }
}
```

---

## 10. Utility Types Útiles

```typescript
// LAYER: Application

// Partial - Todas las propiedades opcionales
type PartialUser = Partial<User>;

// Pick - Seleccionar solo algunas propiedades
type UserSummary = Pick<User, 'id' | 'email'>;

// Omit - Quitar propiedades
type CreateUserInput = Omit<User, 'id' | 'createdAt'>;

// Required - Todas obligatorias
type RequiredUser = Required<PartialUser>;

// Readonly - Inmutable
type ImmutableUser = Readonly<User>;

// Record - Mapa tipado
type UserCache = Record<UserId, User>;

// ReturnType - Inferir el retorno de una función
type ApiResponse = ReturnType<typeof fetchUser>;

// Parameters - Inferir parámetros
type CreateUserParams = Parameters<typeof createUser>;
```

---

## Checklist Type Safe

- [ ] `strict: true` en tsconfig.json
- [ ] Cero `any` en código nuevo
- [ ] Usar `unknown` + type guards en lugar de `any`
- [ ] Retornar `null` explícitamente, nunca asumir existencia
- [ ] Branded types para IDs y strings semánticamente diferentes
- [ ] DTOs separados por capa (no reutilizar entidades)
- [ ] Switch exhaustive con `never` check
- [ ] Funciones públicas con tipos de retorno explícitos
- [ ] Sin `as` (type assertions) sin justificación
- [ ] Usar Zod/io-ts para validación runtime de external data

---

## TL;DR

```typescript
// ❌ NO
function x(a: any): any { }

// ✅ SÍ  
function createUser(input: CreateUserDTO): Promise<User | null> {
  // Types everywhere, strict mode, null checks
}
```
