---
name: skill-dead-code-legacy
description: >-
  Dead code and legacy pattern detector for any codebase.
  Identifies unused exports, unreachable code, zombie routes, unused dependencies,
  deprecated APIs, outdated idioms, and technical debt accumulation.
  Produces a severity-ranked cleanup report with safe removal recommendations.
compatibility: Framework agnostic. Works with Node.js, TypeScript, Python, Java, React, Vue, Next.js, Angular, Express, NestJS.
metadata:
  author: leifermendez
  version: "1.0"
  tags: "dead-code, legacy, technical-debt, unused-exports, deprecated, cleanup, refactor, maintenance"
---

## Overview

This skill performs a systematic dead code and legacy pattern audit of any codebase. When invoked, it scans source files for unused exports, unreachable code, zombie routes, orphaned tests, deprecated API usage, outdated dependencies, legacy idioms, and accumulated technical debt markers. It produces a three-tier severity report (REMOVE NOW / REVIEW & CLEAN / TECHNICAL DEBT) with safe removal guidance.

**Trigger phrases:** "dead code audit", "find unused code", "legacy cleanup", "deprecated APIs", "zombie routes", "remove dead code", "technical debt scan", "unused dependencies", "TODO cleanup".

## Parameters

The agent requires access to the project's source files. Before starting the scan, confirm:

| Input | Required | Description |
|---|---|---|
| Project source directory | Yes | The root path or `src/` folder to scan |
| Language / framework | Auto-detected | Detected from `package.json`, file extensions, config files |
| Scope | Optional | Limit scan to dead code only, legacy only, or technical debt only |

If no project path is provided, ask the user to specify the directory or share the relevant files.

## Returns

This skill produces a structured **Dead Code & Legacy Audit Report** containing:
- Stack detected (language, framework, package manager)
- Scan summary (files scanned, dead code findings, legacy findings, tech debt markers)
- Severity-ranked findings: REMOVE NOW / REVIEW & CLEAN / TECHNICAL DEBT
- For each finding: file path, line number, description, and safe-to-remove verdict
- Top 3 Quick Wins with before/after code snippets

## Error Handling

| Situation | Action |
|---|---|
| No source files found | Ask the user to confirm the project path; check for non-standard source directories |
| Unsupported language | Report which checks are unsupported; run applicable checks only |
| Cannot determine if export is used externally | Mark as REVIEW, not REMOVE — flag the uncertainty explicitly |
| No dead code or legacy patterns found | Report "No issues found in scanned scope" — do not fabricate findings |
| File is a public library/SDK | Warn that unused export checks should be skipped for public API surface |

---

## Core Philosophy: Evidence-Based Removal Only

This skill identifies code that is **provably unused, deprecated, or carrying technical debt** based on observable signals. It does NOT recommend removing code based on style preferences or subjective "this looks old" judgments.

### What We Detect

- **Dead Code** — code that is defined but never executed or referenced
- **Legacy Patterns** — idioms, APIs, and dependencies that are deprecated or superseded
- **Technical Debt Signals** — accumulated markers that indicate deferred work

### What We Do NOT Do

- Flag code as "legacy" based on age alone — old code that works is not a problem
- Recommend removing code without verifying it is not used elsewhere
- Confuse unfamiliar patterns with bad patterns
- Remove feature flags or conditionals without confirming the business context

### Safety Rule

> Before marking anything as removable, always check: is it exported and possibly consumed by an external caller? Is it a public API? When in doubt, mark it as REVIEW, not REMOVE.

---

## Step 1 — Context Discovery

Identify the stack to apply the right detection checks.

### Detect Language and Runtime

| Signal | Stack |
|---|---|
| `package.json` present | Node.js / JavaScript / TypeScript |
| `tsconfig.json` present | TypeScript |
| `requirements.txt` or `pyproject.toml` | Python |
| `pom.xml` or `build.gradle` | Java / Kotlin |
| `Gemfile` | Ruby |
| `go.mod` | Go |
| `composer.json` | PHP |

### Detect Framework

| Signal | Framework |
|---|---|
| `react`, `react-dom` in `package.json` | React |
| `next` in `package.json` | Next.js |
| `@nestjs/core` in `package.json` | NestJS |
| `express` in `package.json` | Express |
| `@angular/core` in `package.json` | Angular |
| `vue` in `package.json` | Vue.js |
| `django` in `requirements.txt` | Django |
| `flask` in `requirements.txt` | Flask |

### Identify Entry Points

Before scanning, locate the project's entry points — these anchor the reachability analysis:
- Node.js: `main` field in `package.json`, or `src/index.ts`, `src/main.ts`
- Next.js: `pages/`, `app/` directories
- NestJS: `AppModule` bootstrap
- Express: the file that calls `app.listen()`
- Python: `__main__.py`, `manage.py`, `app.py`

---

## Step 2 — The Dead Code & Legacy Scan

Run all applicable checks based on the detected stack. Note the file path and line numbers for every finding.

---

### DEAD CODE CHECKS (D series)

#### D1 — Unused Exports
**Pattern:** Functions, classes, constants, or types that are exported but never imported by any other file in the project.

**What to look for:**
```typescript
// PROBLEM — exported but grep shows zero imports of 'formatCurrency' elsewhere
export function formatCurrency(amount: number, currency: string): string { ... }

// PROBLEM — exported interface used nowhere
export interface LegacyUserDTO { ... }

// PROBLEM — re-export barrel that includes removed modules
export { OldPaymentService } from './payments/old-payment.service';
```

**How to verify:** Search the entire codebase for the export name as an import. If zero results → dead export.

**Severity:** REVIEW & CLEAN — could be a public API consumed externally. Confirm scope before removing.

**Fix reference:** `references/dead-code-patterns.md#unused-exports`

---

#### D2 — Unreachable Code
**Pattern:** Code that appears after an unconditional control flow statement (`return`, `throw`, `break`, `continue`) in the same block — guaranteed to never execute.

**What to look for:**
```typescript
// PROBLEM — lines 3-5 never execute
function processOrder(order: Order) {
  if (!order.id) throw new Error('No ID');
  return order;
  console.log('Order processed'); // UNREACHABLE
  order.processed = true;         // UNREACHABLE
}

// PROBLEM — condition is always false (literal comparison)
if (false) {
  legacyMigration(); // UNREACHABLE
}

// PROBLEM — dead else branch (constant condition)
const FLAG = true;
if (FLAG) {
  newFlow();
} else {
  oldFlow(); // UNREACHABLE — FLAG is always true
}
```

**Severity:** REMOVE NOW — unreachable code is guaranteed waste and often indicates a bug (the developer expected it to run).

**Fix reference:** `references/dead-code-patterns.md#unreachable-code`

---

#### D3 — Zombie Routes
**Pattern:** HTTP route definitions that exist in the router but have no corresponding handler implementation, no tests, and no documented consumers.

**What to look for:**
```typescript
// PROBLEM — route defined but handler is undefined or points to a deleted file
router.get('/api/v1/legacy/reports', legacyReportController.getAll);
// legacyReportController.getAll does not exist

// PROBLEM — route registered but immediately overridden by a newer version
router.post('/api/users', oldUserController.create);    // zombie — same path
router.post('/api/users', newUserController.create);    // this one actually runs

// PROBLEM — route for a feature that was removed
router.delete('/api/beta/invitations/:id', invitationController.delete);
// invitationController module was deleted 6 months ago
```

**How to verify:** Check that the handler function exists and is reachable from the route definition.

**Severity:** REMOVE NOW — zombie routes expose broken endpoints that return 500 or unexpected responses.

**Fix reference:** `references/dead-code-patterns.md#zombie-routes`

---

#### D4 — Unused Dependencies
**Pattern:** Packages listed in `package.json` (`dependencies` or `devDependencies`) or `requirements.txt` that are never imported in any source file.

**What to look for:**
```json
// package.json — spot these packages, then grep source for their import
{
  "dependencies": {
    "moment": "^2.29.4",        // grep: import moment / require('moment') → 0 results?
    "lodash": "^4.17.21",       // grep: from 'lodash' → 0 results?
    "xml2js": "^0.6.0",         // grep: require('xml2js') → 0 results?
    "request": "^2.88.2"        // deprecated AND unused
  }
}
```

**High-value targets** (large packages that are commonly orphaned):
- `moment` (~547KB) — often replaced by `date-fns` or native `Intl`
- `lodash` (~70KB) — often replaced by native array methods
- `request` (deprecated) — replaced by `axios`, `node-fetch`, or native `fetch`
- `bluebird` — replaced by native Promises in Node.js 10+

**Severity:** REMOVE NOW for deprecated packages; REVIEW & CLEAN for large active packages that may be indirect dependencies.

**Fix reference:** `references/dead-code-patterns.md#unused-dependencies`

---

#### D5 — Commented-Out Code Blocks
**Pattern:** Three or more consecutive lines of commented-out code that have not been removed after being disabled.

**What to look for:**
```typescript
// PROBLEM — large block of disabled code
// async function sendNotification(userId: string) {
//   const user = await db.user.findUnique({ where: { id: userId } });
//   const email = new Email(user.email);
//   await email.send({ subject: 'Notification', body: template });
// }

// PROBLEM — old implementation kept "just in case"
// const result = users.filter(u => u.active).map(u => u.id);
// const result = activeUserIds; // replaced above
```

**Severity:** REVIEW & CLEAN — if the code is in version control (git), it is already preserved. Commented-out code in production files adds noise without value.

**Fix reference:** `references/tech-debt-signals.md#commented-out-code`

---

#### D6 — Unused Variables and Imports
**Pattern:** Variables declared but never read; modules imported but never used in the file.

**What to look for:**
```typescript
// PROBLEM — imported but never used
import { formatDate } from '../utils/date';  // formatDate never called in this file
import type { OldUserSchema } from '../types'; // OldUserSchema never referenced

// PROBLEM — variable assigned but never read
const MAX_RETRIES = 3;  // never referenced after declaration
let userCache = {};      // assigned, never read

// PROBLEM — destructured but unused
const { id, name, legacyField } = user; // legacyField never used
```

**TypeScript signal:** If `noUnusedLocals` and `noUnusedParameters` are not enabled in `tsconfig.json`, flag this as a configuration gap too.

**Severity:** REMOVE NOW for imports; REVIEW & CLEAN for variables (some may be intentional placeholders).

---

### LEGACY CHECKS (L series)

#### L1 — Deprecated API Usage
**Pattern:** Calls to framework or language APIs that are marked deprecated, removed in the current version, or have a well-known replacement.

**React deprecated APIs:**
```tsx
// PROBLEM — removed in React 18
componentWillMount() { ... }
componentWillReceiveProps(nextProps) { ... }
componentWillUpdate(nextProps, nextState) { ... }

// PROBLEM — string refs (removed in React 19)
<input ref="myInput" />

// PROBLEM — ReactDOM.render (removed in React 18)
ReactDOM.render(<App />, document.getElementById('root'));
```

**Node.js deprecated APIs:**
```javascript
// PROBLEM — deprecated in Node.js 14+
const { createCipher } = require('crypto'); // use createCipheriv
new Buffer(size); // use Buffer.alloc(size)
require.resolve.paths(request); // check Node.js version
```

**Severity:** REVIEW & CLEAN — deprecated APIs still work but will break on the next major upgrade.

**Fix reference:** `references/legacy-patterns.md#deprecated-apis`

---

#### L2 — Outdated Dependency Versions
**Pattern:** Packages pinned to versions that are 2+ major versions behind the current release, or packages with known security vulnerabilities.

**What to look for:**
```json
{
  "dependencies": {
    "express": "^3.x.x",    // current: 5.x — 2 majors behind
    "webpack": "^3.x.x",    // current: 5.x — 2 majors behind
    "mongoose": "^4.x.x",   // current: 8.x — 4 majors behind
    "typescript": "^3.x.x"  // current: 5.x — 2 majors behind
  }
}
```

**High-risk signals:**
- Any package with a known CVE in `npm audit` / `pip-audit` output
- Packages that have been unmaintained (last publish > 2 years, 0 open PRs)
- Packages whose npm page shows "Deprecated"

**Severity:** REVIEW & CLEAN for outdated; REMOVE NOW for packages with active CVEs.

**Fix reference:** `references/legacy-patterns.md#outdated-deps`

---

#### L3 — Old Language Idioms
**Pattern:** Outdated syntax or patterns that the rest of the codebase has moved away from, creating inconsistency and cognitive overhead.

**What to look for in TypeScript/JavaScript:**
```javascript
// PROBLEM — var in a codebase that uses const/let everywhere
var userId = req.params.id;

// PROBLEM — callback style in an async/await codebase
fs.readFile('./config.json', function(err, data) {  // callback hell
  if (err) { callback(err); return; }
  JSON.parse(data, function(err, config) { ... });
});

// PROBLEM — .then()/.catch() chains mixed with async/await
async function getUser(id) {
  return db.user.findUnique({ where: { id } })
    .then(user => user)      // redundant .then
    .catch(err => { throw err; }); // redundant .catch
}

// PROBLEM — require() in an ESM/TypeScript codebase
const express = require('express'); // should be: import express from 'express'
```

**What to look for in Python:**
```python
# PROBLEM — Python 2 print statement / division / unicode in a Python 3 codebase
print "Hello"          # Python 2 only
result = 5 / 2         # integer division in Python 2 (gives 2, not 2.5)
u"unicode string"      # redundant in Python 3
```

**Severity:** REVIEW & CLEAN — style inconsistency that increases cognitive load for the team.

**Fix reference:** `references/legacy-patterns.md#old-idioms`

---

#### L4 — TODO / FIXME Accumulation
**Pattern:** Comments marked with `TODO`, `FIXME`, `HACK`, `XXX`, or `BUG` that represent deferred work. The presence of many such comments indicates accumulated technical debt.

**Severity mapping:**

| Keyword | Meaning | Severity |
|---|---|---|
| `FIXME` | Known bug, must fix | REMOVE NOW (the bug should be fixed) |
| `BUG` | Active defect | REMOVE NOW |
| `HACK` | Temporary workaround | REVIEW & CLEAN |
| `XXX` | Dangerous or broken | REVIEW & CLEAN |
| `TODO` | Planned improvement | TECHNICAL DEBT |
| `NOTE` | Informational | TECHNICAL DEBT (may be outdated) |

**What to look for:**
```typescript
// FIXME: this crashes when user has no profile — known since March 2023
// TODO: replace with JWT — added 2 years ago, session auth still in place
// HACK: workaround for bug in library X v2.3 — library is now at v4.1
// XXX: this function is not thread-safe
```

**Reporting:** Count all occurrences by keyword. List the top 5 oldest or highest-severity ones with file and line.

**Fix reference:** `references/tech-debt-signals.md#todo-taxonomy`

---

#### L5 — Orphaned Test Files
**Pattern:** Test files (`.spec.ts`, `.test.ts`, `_test.py`, `Test*.java`) that import or reference modules that no longer exist — typically because the source file was renamed, moved, or deleted.

**What to look for:**
```typescript
// PROBLEM — source file was deleted, test remains
import { OldPaymentService } from '../payments/old-payment.service'; // file does not exist
```

**How to verify:** For each `import` in a test file, confirm the target file exists at the resolved path.

**Severity:** REMOVE NOW — orphaned tests produce import errors, inflate test suite complexity, and cause CI failures.

**Fix reference:** `references/dead-code-patterns.md#orphaned-tests`

---

#### L6 — Permanent Feature Flags (Dead Branches)
**Pattern:** Feature flag conditionals where the flag value is a constant that never changes — making one branch permanently unreachable.

**What to look for:**
```typescript
// PROBLEM — constant flag creates unreachable else branch
const USE_NEW_CHECKOUT = true; // set to true 18 months ago, never toggled

if (USE_NEW_CHECKOUT) {
  return newCheckoutFlow();
} else {
  return legacyCheckoutFlow(); // DEAD — never executes
}

// PROBLEM — env variable that is always set to the same value in all environments
if (process.env.FEATURE_NEW_DASHBOARD === 'true') { // always true in .env
  return NewDashboard;
} else {
  return OldDashboard; // dead in practice
}
```

**Severity:** REVIEW & CLEAN — confirm with the team that the flag is permanent, then inline the live branch and remove the dead one.

**Fix reference:** `references/dead-code-patterns.md#feature-flags`

---

## Step 3 — Audit Report

After running all applicable checks, produce this exact output:

```text
╔══════════════════════════════════════╗
║     DEAD CODE & LEGACY AUDIT         ║
╚══════════════════════════════════════╝

STACK DETECTED:
  Language:    <detected>
  Framework:   <detected or "not found">
  Package Mgr: <npm / pip / maven / other>

SCAN SUMMARY:
  Files scanned:       <count>
  Dead code findings:  <count>
  Legacy findings:     <count>
  Tech debt markers:   <count>

────────────────────────────────────────
🔴 REMOVE NOW   (<count> findings)
────────────────────────────────────────
Safe to delete — confirmed unused, deprecated, or broken.

[D2] Unreachable Code
  File: src/utils/parser.ts:47
  Detail: 3 lines after unconditional return statement.
  Safe to remove: Yes — guaranteed dead code.

[D3] Zombie Route
  File: src/routes/api.ts:82
  Detail: GET /api/v1/legacy/reports → handler legacyReportController.getAll not found.
  Safe to remove: Yes — handler does not exist.

[D4] Unused Dependency
  Package: moment (547KB gzipped)
  Detail: Zero imports found in source files.
  Safe to remove: Run `npm uninstall moment`

────────────────────────────────────────
🟡 REVIEW & CLEAN   (<count> findings)
────────────────────────────────────────
Verify before removing — may have external consumers or intentional purpose.

[D1] Unused Export
  File: src/lib/formatters.ts — formatCurrency()
  Detail: No internal imports found. May be consumed by external packages.
  Action: Confirm no external consumers, then remove export + function.

[L1] Deprecated API
  File: src/components/UserCard.tsx:12
  Detail: componentWillMount() — removed in React 18.
  Action: Migrate to componentDidMount() or useEffect().

[L2] Outdated Dependency
  Package: webpack@3.12.0 — current: 5.x (2 majors behind).
  Action: Review breaking changes, plan upgrade or replacement.

────────────────────────────────────────
🔵 TECHNICAL DEBT   (<count> findings)
────────────────────────────────────────
Deferred work — not urgent but should be tracked and scheduled.

[L4] TODO/FIXME Accumulation
  Total: 23 markers (8 FIXME, 12 TODO, 3 HACK)
  Top priority:
    FIXME src/auth/session.ts:5 — "crashes when user has no profile"
    HACK  src/payments/stripe.ts:88 — "workaround for Stripe SDK v2 bug" (now on v4)
    TODO  src/api/users.ts:120 — "replace with JWT" (added 14 months ago)

[L3] Mixed Idioms
  15 files use var declarations in a const/let codebase.
  8 files mix require() with ES import statements.

════════════════════════════════════════
⭐ TOP 3 QUICK WINS
════════════════════════════════════════
Highest impact, lowest risk — do these first.

#1 [D4] Remove unused dependencies
   npm uninstall moment lodash xml2js
   Impact: ~620KB removed from bundle. Zero code changes required.

#2 [D2] Delete unreachable code blocks
   4 confirmed unreachable blocks across 3 files.
   Impact: Cleaner logic, no risk — code is guaranteed to not run.

#3 [L1] Fix deprecated React lifecycle methods
   2 components use componentWillMount — breaks in React 18.
   Impact: Prevents runtime crash on React upgrade.
```

---

## Quick Win Output Format

For each of the top 3 findings, output:

```text
QUICK WIN #<n> — [Check ID] <Check Name>
File: <path:line>

BEFORE:
  <problematic code>

AFTER:
  <fixed code>

WHY: <one sentence on the impact>
```

---

## References

- [`references/dead-code-patterns.md`](references/dead-code-patterns.md) — unused exports, unreachable code, zombie routes, orphaned tests, feature flags
- [`references/legacy-patterns.md`](references/legacy-patterns.md) — deprecated React/Node.js APIs, old JS idioms, outdated dependencies
- [`references/tech-debt-signals.md`](references/tech-debt-signals.md) — TODO/FIXME taxonomy, commented-out code, duplication detection
