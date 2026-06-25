# Technical Debt Signals

Reference guide for detecting, categorizing, and prioritizing technical debt in a codebase.

---

## Core Principle

Technical debt is not inherently bad — some is taken deliberately to ship faster. The problem is **untracked, unacknowledged, or forgotten debt** that silently grows. This reference helps surface and quantify it.

> "Technical debt is only a problem when it's invisible." — Ward Cunningham

---

## TODO / FIXME Taxonomy {#todo-taxonomy}

### Severity Classification

Not all TODOs are equal. Classify by keyword to prioritize:

| Keyword | Meaning | Severity | Action |
|---|---|---|---|
| `FIXME` | Known bug or broken behavior | CRITICAL | Fix before next release |
| `BUG` | Active defect | CRITICAL | Fix before next release |
| `HACK` | Temporary workaround for a known problem | HIGH | Schedule for next major sprint |
| `XXX` | Dangerous, broken, or poorly understood code | HIGH | Review immediately |
| `TODO` | Planned improvement, not yet urgent | MEDIUM | Backlog and track |
| `NOTE` | Informational context for future developers | LOW | Review for accuracy; may be outdated |
| `OPTIMIZE` | Performance improvement identified but deferred | LOW | Validate with profiling before acting |

### How to Count and Report

**Count all markers by keyword:**
```bash
# Count by type
grep -rn "// FIXME" src/ --include="*.ts" | wc -l
grep -rn "// TODO" src/ --include="*.ts" | wc -l
grep -rn "// HACK" src/ --include="*.ts" | wc -l

# Show all with file and line
grep -rn "// \(FIXME\|TODO\|HACK\|XXX\|BUG\)" src/ --include="*.ts"

# Python
grep -rn "# FIXME\|# TODO\|# HACK\|# XXX" . --include="*.py"
```

### Aging Analysis

The older a TODO, the more likely the context behind it is lost — and the more likely it represents permanent technical debt rather than planned work.

**Detect TODO age with git blame:**
```bash
# Find when a specific TODO was introduced
git log -S "TODO: replace with JWT" --oneline

# Show all TODOs with the commit date they were added
git log --all -p | grep -B5 "TODO:" | grep -E "^Date:|TODO:"
```

**Staleness thresholds:**

| Age | Signal |
|---|---|
| < 1 month | Recently added — likely intentional |
| 1–6 months | Should be in the backlog |
| 6–12 months | Elevated risk — context may be partially lost |
| > 12 months | High risk — context likely lost; re-evaluate from scratch |
| > 2 years | Treat as permanent unless a champion owns it |

### HACK Detection Pattern

A HACK is often a workaround for a bug in a library. When the library is upgraded, the workaround may:
1. Still be needed (the bug was never fixed)
2. Break because the workaround assumed the old behavior
3. Be unnecessary and can be removed

**Always cross-reference HACK comments with the library version:**
```typescript
// HACK: workaround for Stripe SDK v2 bug where webhook events are duplicated
// Current version: stripe@2.15.0
```
**If current version is v4.x, review whether the bug was fixed in the changelog.**

---

## Commented-Out Code {#commented-out-code}

### What It Is
Blocks of source code that have been commented out instead of deleted — typically because the developer was uncertain about removing it or wanted to "keep it just in case."

### Why It Is a Problem
- Creates visual noise and confusion ("is this code intentional or accidental?")
- Developers preserve it out of fear, which means it grows
- If the code is needed, git history is the right place to recover it — not inline comments
- Old commented code becomes stale and misleading as the surrounding code evolves

### Detection Heuristic
Flag as "commented-out code" when a comment block meets ALL of:
1. Three or more consecutive lines starting with `//` or `#` or wrapped in `/* ... */`
2. The content looks like executable code (contains `=`, `(`, `)`, `{`, `}`, `return`, `await`, etc.)
3. The block has no surrounding prose that explains it as documentation

```typescript
// PROBLEM — clearly code, not prose
// async function sendNotification(userId: string) {
//   const user = await db.user.findUnique({ where: { id: userId } });
//   const email = new Email(user.email);
//   await email.send({ subject: 'Notification' });
// }

// NOT a problem — prose comment explaining context
// The rate limiter is intentionally disabled for internal IP ranges
// because the internal tooling does not authenticate with user tokens.
// See ADR-012 for the decision record.
const isRateLimited = !isInternalIp(req.ip);
```

### Safe Removal Rule
If the code is tracked in git (which all production code should be), commented-out code is already "preserved" in the history. Removing it from the file loses nothing.

```bash
# Recover old code from git history if needed
git log --all --full-history -- src/notifications/email.service.ts
git show <commit-hash>:src/notifications/email.service.ts
```

---

## Code Duplication {#duplication}

### What It Is
The same logic, algorithm, or data transformation copied into multiple places instead of being extracted into a shared function or module. Known as the DRY (Don't Repeat Yourself) principle violation.

### Why It Matters
- A bug fix or change must be applied in N places — and developers will inevitably miss some
- Differing copies accumulate subtle differences over time (one gets updated, others don't)
- Inflates codebase size, making navigation harder

### Categories of Duplication

**Category 1 — Exact copy:**
```typescript
// In user.service.ts
function formatUserName(first: string, last: string): string {
  return `${first.trim()} ${last.trim()}`.trim();
}

// In order.service.ts — identical function
function formatCustomerName(first: string, last: string): string {
  return `${first.trim()} ${last.trim()}`.trim();
}
```

**Category 2 — Near-duplicate (same logic, slightly different variable names):**
```typescript
// In sendEmail()
const payload = { to: user.email, subject, body };
const response = await fetch('/api/email', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
  body: JSON.stringify(payload)
});
if (!response.ok) throw new Error('Email failed');

// In sendSms() — same fetch pattern, different endpoint
const payload = { to: user.phone, message };
const response = await fetch('/api/sms', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
  body: JSON.stringify(payload)
});
if (!response.ok) throw new Error('SMS failed');
```

**Category 3 — Structural duplication (same pattern, different entities):**
```typescript
// CRUD operations copy-pasted for every entity with only the model name changing
async function createUser(data) { return db.user.create({ data }); }
async function updateUser(id, data) { return db.user.update({ where: { id }, data }); }
async function deleteUser(id) { return db.user.delete({ where: { id } }); }

async function createProduct(data) { return db.product.create({ data }); }
async function updateProduct(id, data) { return db.product.update({ where: { id }, data }); }
async function deleteProduct(id) { return db.product.delete({ where: { id } }); }
```

### Detection Tools

```bash
# jscpd — JavaScript/TypeScript copy-paste detector
npx jscpd src/ --min-lines 5 --min-tokens 50

# PMD CPD — works on many languages including Java, Python, JavaScript
# https://pmd.github.io/pmd/pmd_userdocs_cpd.html

# SonarQube / SonarCloud — detects duplication across all major languages
```

### When Duplication is Acceptable
Not all duplication should be extracted. Apply the Rule of Three:
- **Once**: write it inline
- **Twice**: note the duplication; consider if a pattern is emerging
- **Three times**: extract to a shared function/module

Premature extraction creates the wrong abstraction. Wait until you see the real pattern.

---

## Stale Configuration and Environment Files {#stale-config}

### What It Is
Configuration keys, environment variables, or feature flags that are defined in config files but are no longer referenced in the application code.

### What to Look For

**Unused environment variables:**
```bash
# .env file contains:
OLD_PAYMENT_API_URL=https://old-payment.example.com
LEGACY_FEATURE_ENABLED=true
DEPRECATED_SERVICE_KEY=abc123

# Grep source for each variable name
grep -rn "OLD_PAYMENT_API_URL" src/ --include="*.ts"
# → 0 results → stale env variable
```

**Unused config keys (JSON/YAML):**
```json
// config/app.json
{
  "legacyApiUrl": "https://old-api.example.com",   // not referenced in code?
  "maxRetries": 3,
  "oldCacheStrategy": "memory"  // grep: "oldCacheStrategy" → 0 results?
}
```

### Why Stale Config is a Risk
- New developers assume all config keys are in use — they may be confused or misled
- Secret keys that are "unused" may still have access privileges that should be revoked
- CI/CD pipelines may fail if a "required" env variable is actually dead

---

## Missing or Outdated Documentation Signals {#docs}

### Documentation Debt Indicators

These are signals that documentation has not kept pace with code changes:

| Signal | Location | Implication |
|---|---|---|
| JSDoc/TSDoc comments with wrong parameter names | Function declarations | Parameters were renamed; docs not updated |
| README describes a feature that no longer exists | README.md | Feature was removed without updating docs |
| API documentation references deleted endpoints | `/docs` or Swagger | API was changed; docs are stale |
| `@deprecated` JSDoc without a `@see` or `@since` | Any file | Developer marked it deprecated but didn't say what to use instead |
| Comments reference ticket numbers that are closed | Inline comments | Context exists in tickets; comment is now noise |

**Example of a bad `@deprecated` comment:**
```typescript
/**
 * @deprecated
 */
export function legacyFetch(url: string) { ... }
// Missing: since when? What should callers use instead?

/**
 * @deprecated since v2.4.0 — use httpClient.get() from '@/lib/http-client' instead.
 */
export function legacyFetch(url: string) { ... }
// Good: tells callers exactly what to do
```

### Minimum Documentation for Deprecated Code
When marking something as deprecated rather than removing it (e.g., because it's a public API):
1. Add `@deprecated since <version>` JSDoc tag
2. Add `@see <replacement>` pointing to the replacement
3. Add a `console.warn()` or logger call inside the function body so callers get a runtime notice
4. Set a removal target version or date in the comment
