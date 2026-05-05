# Recommended Books (FANG-Level)

> **Essential reading for mastering Spec-Driven Development and Domain-Driven Design.**

---

## Foundation Books

### Domain-Driven Design: Tackling Complexity in the Heart of Software
**Author**: Eric Evans  
**Nickname**: "The Blue Book"  
**Level**: Intermediate to Advanced  
**Anchor**: `#domain-driven-design-blue-book`

**Why Read It:**
- The original DDD bible
- Comprehensive coverage of strategic and tactical patterns
- Essential for understanding bounded contexts and ubiquitous language

**Best For:**
- Understanding the philosophy behind DDD
- Learning strategic patterns (bounded contexts, context maps)
- Designing complex domain models

**When to Read:**
- 📖 **Phase 3**: During problem decomposition
- 📖 **Phase 4**: When defining bounded contexts

**Key Takeaways:**
- Ubiquitous Language is sacred
- Bounded Contexts define linguistic boundaries
- Not everything needs to be DDD - choose your battles

---

### Implementing Domain-Driven Design
**Author**: Vaughn Vernon  
**Nickname**: "The Red Book"  
**Level**: Intermediate to Advanced  
**Anchor**: `#implementing-ddd-red-book`

**Why Read It:**
- Practical implementation guidance
- Code examples in multiple languages
- Real-world case studies

**Best For:**
- Implementing aggregates, entities, value objects
- Architecture Decision Records (ADRs)
- Testing domain logic

**When to Read:**
- 📖 **Phase 4**: Writing ADRs
- 📖 **Phase 5**: Implementation patterns
- 📖 **Phase 6**: Coding aggregates

**Key Takeaways:**
- Aggregate design rules (transaction boundaries)
- Repository pattern implementation
- Domain events and eventual consistency

---

### Domain-Driven Design Distilled
**Author**: Vaughn Vernon  
**Level**: Beginner  
**Anchor**: `#ddd-distilled`

**Why Read It:**
- Quick introduction to DDD
- Covers essentials without overwhelming detail
- Good for onboarding team members

**Best For:**
- Team members new to DDD
- Quick reference for core concepts
- Convincing stakeholders about DDD value

**When to Read:**
- 📖 **Phase 1**: Quick onboarding before discovery
- 📖 **Sprint 0**: Team education

**Key Takeaways:**
- Core DDD concepts in 200 pages
- When to use and when NOT to use DDD
- Strategic vs Tactical patterns overview

---

## Architecture & System Design

### Designing Data-Intensive Applications
**Author**: Martin Kleppmann  
**Level**: Advanced  
**Anchor**: `#designing-data-intensive-applications`

**Why Read It:**
- Deep technical knowledge for distributed systems
- Database internals and distributed data
- Trade-offs in system design

**Best For:**
- Understanding data persistence options
- Designing for scalability (10x rule)
- Event sourcing and stream processing

**When to Read:**
- 📖 **Phase 2**: Technical scope analysis
- 📖 **Phase 3**: Decomposition decisions
- 📖 **ADR-002**: Data persistence strategy

**Key Takeaways:**
- Data models and query languages
- Storage and retrieval internals
- Distributed systems challenges (consistency, availability)

---

### Building Microservices: Designing Fine-Grained Systems
**Author**: Sam Newman  
**Level**: Intermediate  
**Anchor**: `#building-microservices`

**Why Read It:**
- Practical microservices guidance
- Integration patterns
- Decomposition strategies

**Best For:**
- Defining bounded context boundaries
- Integration patterns between services
- Deployment and monitoring

**When to Read:**
- 📖 **Phase 3**: Bounded context identification
- 📖 **Phase 4**: Architecture style ADR
- 📖 **Phase 7**: Observability setup

**Key Takeaways:**
- Service boundaries align with bounded contexts
- Database per service pattern
- Handling distributed system complexity

---

## Patterns & Practices

### Patterns of Enterprise Application Architecture
**Author**: Martin Fowler  
**Level**: Intermediate to Advanced  
**Anchor**: `#patterns-of-enterprise-architecture`

**Why Read It:**
- Catalog of enterprise patterns
- Repository, Unit of Work, Lazy Loading
- Foundation for DDD implementation

**Best For:**
- Repository pattern implementation
- Data mapper vs Active Record
- Session and transaction management

**When to Read:**
- 📖 **Phase 5**: Implementation patterns
- 📖 **Tactical DDD**: Code structure decisions

---

### Enterprise Integration Patterns
**Authors**: Gregor Hohpe, Bobby Woolf  
**Level**: Intermediate  
**Anchor**: `#enterprise-integration-patterns`

**Why Read It:**
- Messaging patterns for distributed systems
- Event-driven architecture
- Asynchronous communication

**Best For:**
- Domain event implementation
- Message bus architecture
- Integration between bounded contexts

**When to Read:**
- 📖 **ADR-003**: Communication patterns decision
- 📖 **Phase 6**: Event-driven implementation

---

## Software Design & Engineering

### Clean Architecture
**Author**: Robert C. Martin (Uncle Bob)  
**Level**: Intermediate  
**Anchor**: `#clean-architecture`

**Why Read It:**
- Dependency management
- Layered architecture
- Testability

**Best For:**
- Layer boundaries in SDD
- Dependency direction
- Hexagonal/Ports and Adapters architecture

**When to Read:**
- 📖 **Phase 3**: Implementation decomposition
- 📖 **Phase 5**: Code organization

---

### The Pragmatic Programmer
**Authors**: Andrew Hunt, David Thomas  
**Level**: Beginner to Intermediate  
**Anchor**: `#pragmatic-programmer`

**Why Read It:**
- General software engineering wisdom
- DRY, orthogonality, reversibility
- Pragmatic approach to development

**Best For:**
- General development practices
- Code quality
- Engineering mindset

**When to Read:**
- 📖 **Any Phase**: General reference

---

## Reading Roadmap

### For DDD Beginners
```
1. Domain-Driven Design Distilled (quick start)
2. The Pragmatic Programmer (foundations)
3. Implementing Domain-Driven Design (practical)
4. Domain-Driven Design (deep dive)
```

### For System Architects
```
1. Domain-Driven Design (strategic patterns)
2. Building Microservices (service boundaries)
3. Designing Data-Intensive Applications (technical depth)
4. Enterprise Integration Patterns (messaging)
```

### For Implementers
```
1. Implementing Domain-Driven Design (tactical patterns)
2. Clean Architecture (code structure)
3. Patterns of Enterprise Application Architecture (repositories)
4. Domain-Driven Design (complete understanding)
```

---

## Online Resources

- **Virtual DDD Community**: [virtualddd.com](https://virtualddd.com)
- **DDD Europe Conference**: YouTube recordings
- **Event Modeling**: [eventmodeling.org](https://eventmodeling.org)
- **Martin Fowler's Bliki**: [martinfowler.com](https://martinfowler.com)

---

## Back to Main Document

- [Back to SKILL.md](../SKILL.md)
- [DDD Pattern Library](ddd-pattern-library.md)
- [DDD Tactics](ddd-tactics.md)
