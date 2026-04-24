/**
 * LAYER: Reference / Code Style
 * Contains: Early Return Pattern
 * Purpose: Document the early return pattern for clean, flat code
 */

# Early Return Pattern (Guard Clauses)

## ¿Qué es?

El patrón **Early Return** (o Guard Clauses) consiste en retornar/salir de una función lo antes posible cuando se detectan condiciones excepcionales o de error, evitando anidación profunda de condicionales.

## El Problema: Código en forma de "pirámide de la muerte"

```typescript
// ❌ MAL: Anidación profunda (Pyramid of Doom)
async function processUser(userId: string): Promise<User> {
  const user = await userRepository.findById(userId);
  
  if (user) {
    if (user.isActive) {
      if (user.emailVerified) {
        if (!user.isBanned) {
          // ... finalmente la lógica principal
          return user;
        } else {
          throw new Error('User is banned');
        }
      } else {
        throw new Error('Email not verified');
      }
    } else {
      throw new Error('User is inactive');
    }
  } else {
    throw new Error('User not found');
  }
}
```

**Problemas:**
- Indentación excesiva (4+ niveles)
- Difícil de leer el flujo principal
- El "código feliz" está escondido al final
- Difícil de mantener y agregar nuevas condiciones

## La Solución: Early Returns

```typescript
// ✅ BIEN: Guard clauses, código plano
async function processUser(userId: string): Promise<User> {
  const user = await userRepository.findById(userId);
  
  // Guard clauses: validaciones primero, salida inmediata
  if (!user) {
    throw new Error('User not found');
  }
  
  if (!user.isActive) {
    throw new Error('User is inactive');
  }
  
  if (!user.emailVerified) {
    throw new Error('Email not verified');
  }
  
  if (user.isBanned) {
    throw new Error('User is banned');
  }
  
  // La lógica principal está al nivel 0 de indentación
  return user;
}
```

## Beneficios

| Antes (Nested) | Después (Early Return) |
|----------------|------------------------|
| 4 niveles de indentación | 1 nivel de indentación |
| Lógica principal al final | Lógica principal visible |
| Difícil seguir el flujo | Flujo lineal, top-to-bottom |
| Agregar validaciones complejo | Agregar validaciones es trivial |

## Casos de Uso Comunes

### 1. Validación de Input

```typescript
// ❌ MAL
function calculateDiscount(order: Order): number {
  if (order && order.items) {
    if (order.items.length > 0) {
      if (order.totalAmount > 0) {
        // ... lógica
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  } else {
    return 0;
  }
}

// ✅ BIEN
function calculateDiscount(order: Order): number {
  if (!order?.items?.length) return 0;
  if (order.totalAmount <= 0) return 0;
  
  // Lógica principal
  return order.totalAmount * 0.1;
}
```

### 2. Permisos/Autorización

```typescript
// ❌ MAL
async function deletePost(userId: string, postId: string): Promise<void> {
  const user = await getUser(userId);
  
  if (user) {
    const post = await getPost(postId);
    
    if (post) {
      if (user.isAdmin || post.authorId === userId) {
        await postRepository.delete(postId);
      } else {
        throw new ForbiddenError();
      }
    } else {
      throw new NotFoundError('Post');
    }
  } else {
    throw new NotFoundError('User');
  }
}

// ✅ BIEN
async function deletePost(userId: string, postId: string): Promise<void> {
  const user = await getUser(userId);
  if (!user) throw new NotFoundError('User');
  
  const post = await getPost(postId);
  if (!post) throw new NotFoundError('Post');
  
  const canDelete = user.isAdmin || post.authorId === userId;
  if (!canDelete) throw new ForbiddenError();
  
  await postRepository.delete(postId);
}
```

### 3. Use Cases en Clean Architecture

```typescript
// LAYER: Application
export class CreateOrderUseCase {
  async execute(input: CreateOrderDTO): Promise<Order> {
    // Guard clauses de validación
    if (!input.items || input.items.length === 0) {
      throw new ValidationError('Order must have at least one item');
    }
    
    if (input.totalAmount <= 0) {
      throw new ValidationError('Order total must be greater than 0');
    }
    
    // Verificación de dependencias
    const customer = await this.customerRepo.findById(input.customerId);
    if (!customer) {
      throw new NotFoundError('Customer');
    }
    
    if (!customer.isActive) {
      throw new BusinessRuleError('Customer account is suspended');
    }
    
    // Finalmente: la lógica de negocio principal
    const order = Order.create({
      customerId: customer.id,
      items: input.items,
      total: input.totalAmount
    });
    
    await this.orderRepo.save(order);
    
    return order;
  }
}
```

## Reglas de Oro

### 1. Validar de arriba hacia abajo, de simple a complejo

```typescript
async function processPayment(data: PaymentDTO) {
  // 1. Validaciones de formato primero (más simples)
  if (!data.cardNumber || data.cardNumber.length !== 16) {
    throw new ValidationError('Invalid card number');
  }
  
  // 2. Validaciones de negocio
  const customer = await this.customerRepo.findById(data.customerId);
  if (!customer) throw new NotFoundError('Customer');
  
  // 3. Validaciones de estado
  if (customer.hasOutstandingBalance()) {
    throw new BusinessRuleError('Customer has outstanding balance');
  }
  
  // 4. Lógica principal
  // ...
}
```

### 2. Fail Fast (Fallar rápido)

```typescript
// ✅ BIEN: Falla inmediatamente si hay error
function divide(a: number, b: number): number {
  if (b === 0) throw new Error('Cannot divide by zero');
  if (!Number.isFinite(a) || !Number.isFinite(b)) {
    throw new Error('Invalid number');
  }
  
  return a / b;
}
```

### 3. Early return para casos exitosos también

```typescript
// ✅ BIEN: Early return para casos especiales
function getDiscount(user: User): number {
  // Casos especiales primero
  if (user.isVIP) return 0.30;        // 30% VIP
  if (user.isPremium) return 0.20;    // 20% Premium
  if (user.hasSubscription) return 0.15; // 15% Subscribed
  
  // Caso por defecto
  return 0; // Sin descuento
}
```

### 4. Combinar condiciones relacionadas

```typescript
// ❌ MAL: Separados cuando están relacionados
if (!user) return;
if (!user.isActive) return;

// ✅ BIEN: Si la relación es obvia
if (!user?.isActive) return;
```

## Cuándo NO usar Early Return

### 1. Cuando complica la lógica de negocio

```typescript
// ❌ Mal uso: Pierde claridad en lógica con ramas iguales
function processOrder(order: Order) {
  if (order.isUrgent) {
    if (order.total > 1000) {
      processUrgentHighValue(order);
      return;
    }
    processUrgent(order);
    return;
  }
  
  if (order.total > 1000) {
    processHighValue(order);
    return;
  }
  
  processStandard(order);
}

// ✅ Mejor: A veces switch o if-else es más claro
function processOrder(order: Order) {
  const isHighValue = order.total > 1000;
  
  if (order.isUrgent && isHighValue) {
    processUrgentHighValue(order);
  } else if (order.isUrgent) {
    processUrgent(order);
  } else if (isHighValue) {
    processHighValue(order);
  } else {
    processStandard(order);
  }
}
```

### 2. Cuando necesitas limpieza (cleanup)

```typescript
// ⚠️ Cuidado: Early return puede saltarse cleanup
function processFile(filePath: string) {
  const file = openFile(filePath);
  
  if (!file.isValid) {
    // ❌ Olvidaste cerrar el archivo!
    return;
  }
  
  // ...
  file.close();
}

// ✅ Solución: try-finally o using/disposable
function processFile(filePath: string) {
  const file = openFile(filePath);
  
  try {
    if (!file.isValid) return;
    // ...
  } finally {
    file.close(); // Siempre se ejecuta
  }
}
```

## Checklist

- [ ] ¿La lógica principal está al nivel superior (indentación mínima)?
- [ ] ¿Las validaciones vienen primero, en orden de dependencia?
- [ ] ¿Cada guard clause tiene una sola responsabilidad?
- [ ] ¿No hay más de 1-2 niveles de anidación?
- [ ] ¿El flujo es de arriba a abajo, fácil de seguir?

## TL;DR

```typescript
// ❌ NO: Pirámide de la muerte
if (a) {
  if (b) {
    if (c) {
      // lógica
    } else { error }
  } else { error }
} else { error }

// ✅ SÍ: Guard clauses
if (!a) return error;
if (!b) return error;
if (!c) return error;
// lógica
```
