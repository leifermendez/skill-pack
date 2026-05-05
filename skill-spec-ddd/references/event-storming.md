# Event Storming Guide

> **Technique for rapid domain discovery and business process mapping.**

Event Storming is a workshop-based modeling technique for exploring complex business domains. It was created by Alberto Brandolini.

---

## What is Event Storming?

A collaborative modeling technique where domain experts and developers explore the business domain together using:
- **Orange sticky notes**: Domain Events (past tense verbs)
- **Blue sticky notes**: Commands (actions that trigger events)
- **Yellow sticky notes**: Aggregates/Entities
- **Green sticky notes**: User/External System (Actor)
- **Purple sticky notes**: Policies/Process managers
- **Red sticky notes**: Hot spots (problems, questions, issues)

---

## Types of Event Storming

### 1. Big Picture Event Storming
**Goal**: Understand the overall business domain
**Participants**: Domain experts, business analysts, developers
**Duration**: 2-4 hours
**Output**: High-level view of the business processes

### 2. Process Level Event Storming
**Goal**: Design a specific business process
**Participants**: Domain experts, developers, UX designers
**Duration**: 4-8 hours
**Output**: Detailed process flow with commands and aggregates

### 3. Software Design Level Event Storming
**Goal**: Design the software implementation
**Participants**: Developers, architects
**Duration**: 1-2 days
**Output**: Aggregate boundaries, consistency rules, services

---

## How to Run an Event Storming Session

### Preparation
```
□ Large wall or whiteboard (minimum 10 meters)
□ Infinite sticky notes (orange, blue, yellow, green, purple, red)
□ Markers for everyone
□ Room with no chairs (standing keeps energy high)
□ Facilitator (neutral person guiding the session)
□ Domain expert available
```

### Steps

1. **Chaotic Exploration** (10-20 min)
   - Everyone writes domain events on orange stickies
   - No discussion, just write
   - Place on the wall in rough chronological order

2. **Timeline Organization** (20-30 min)
   - Remove duplicates
   - Organize left-to-right (past to future)
   - Group related events

3. **Add Actors & Commands** (30-45 min)
   - Who triggers each event? (green stickies)
   - What action triggers it? (blue stickies)

4. **Identify Aggregates** (30-45 min)
   - Group events around entities (yellow stickies)
   - These become your bounded contexts

5. **Mark Hot Spots** (15-20 min)
   - Red stickies for:
     - Conflicting opinions
     - Missing information
     - Process problems
     - Technical concerns

6. **Create Context Map** (30-60 min)
   - Draw boundaries around aggregates
   - Define relationships between contexts

---

## Example Domain Events

```
OrderReceived
PaymentProcessed
InventoryChecked
OrderShipped
DeliveryConfirmed
InvoiceGenerated
PaymentReceived
OrderCompleted
```

---

## Tips for Success

- **No laptops/phones** during the session
- **Standing is mandatory** (energy level matters)
- **Embrace chaos** in the beginning
- **One facilitator** to guide, not participate
- **Domain expert must be present**
- **Time-box each phase**
- **Take photos** of the final result

---

## Common Mistakes

1. **Wrong tense**: Events must be past tense ("OrderShipped", not "ShipOrder")
2. **Too technical**: Business language, not implementation details
3. **Missing actors**: Every event needs a trigger
4. **Skipping hot spots**: Red stickies are valuable insights
5. **Perfect organization too early**: Let chaos exist in exploration phase

---

## After Event Storming

1. **Document the wall** (high-quality photos)
2. **Create user stories** from the events
3. **Identify bounded contexts** for DDD
4. **Prioritize hot spots** for further investigation
5. **Schedule follow-up** for detailed modeling

---

## Related Resources

- [DDD Pattern Library](ddd-pattern-library.md)
- [DDD Tactics](ddd-tactics.md)
- [Back to SKILL.md](../SKILL.md)
