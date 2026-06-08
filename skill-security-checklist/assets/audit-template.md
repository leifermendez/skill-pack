# Audit Report: {project_name}

## Executive Summary

- **Project**: {path}
- **Languages**: {list}
- **Frameworks**: {list}
- **Architecture**: {pattern} (confidence: {high/medium/low})
- **Overall Health**: {score}/10
- **Critical Issues**: {count}
- **Warnings**: {count}
- **Info**: {count}

---

## 1. Stack Overview

### Detected Technologies

| Technology | Version | Confidence | Pros | Cons |
|------------|---------|------------|------|------|
| {tech} | {version} | {confidence} | {pros} | {cons} |

### Dependency Analysis

| Category | Count | Outdated | Vulnerable | Recommendation |
|----------|-------|----------|------------|----------------|
| Production | {count} | {count} | {count} | {recommendation} |
| Development | {count} | {count} | {count} | {recommendation} |

---

## 2. Architecture Analysis

### Detected Pattern: {pattern}

| Aspect | Finding | Pros | Cons | Severity |
|--------|---------|------|------|----------|
| {aspect} | {finding} | {pros} | {cons} | {severity} |

### Layer Health Score

| Layer | Score | Issues |
|-------|-------|--------|
| Domain | {score}/10 | {issues} |
| Application | {score}/10 | {issues} |
| Infrastructure | {score}/10 | {issues} |
| Interface | {score}/10 | {issues} |

---

## 3. Security Checklist

| Check | Status | Risk | Pros | Cons | Mitigation |
|-------|--------|------|------|------|------------|
| Secrets in code | {status} | {risk} | {pros} | {cons} | {mitigation} |
| SQL injection | {status} | {risk} | {pros} | {cons} | {mitigation} |
| XSS prevention | {status} | {risk} | {pros} | {cons} | {mitigation} |
| Dependency vulns | {status} | {risk} | {pros} | {cons} | {mitigation} |
| HTTPS/TLS | {status} | {risk} | {pros} | {cons} | {mitigation} |
| Input validation | {status} | {risk} | {pros} | {cons} | {mitigation} |
| Authentication | {status} | {risk} | {pros} | {cons} | {mitigation} |
| Authorization | {status} | {risk} | {pros} | {cons} | {mitigation} |
| CORS | {status} | {risk} | {pros} | {cons} | {mitigation} |
| Security headers | {status} | {risk} | {pros} | {cons} | {mitigation} |

---

## 4. Code Quality Checklist

| Metric | Current | Threshold | Status | Risk | Pros | Cons |
|--------|---------|-----------|--------|------|------|------|
| Cyclomatic complexity | {value} | {threshold} | {status} | {risk} | {pros} | {cons} |
| File length | {value} | {threshold} | {status} | {risk} | {pros} | {cons} |
| Function length | {value} | {threshold} | {status} | {risk} | {pros} | {cons} |
| Code duplication | {value} | {threshold} | {status} | {risk} | {pros} | {cons} |
| Test coverage | {value} | {threshold} | {status} | {risk} | {pros} | {cons} |
| Nesting depth | {value} | {threshold} | {status} | {risk} | {pros} | {cons} |

---

## 5. Technical Debt Assessment

| Debt Item | Priority | Effort | Impact | Pros of Fixing | Cons of Delaying |
|-----------|----------|--------|--------|--------------|------------------|
| {item} | {priority} | {effort} | {impact} | {pros} | {cons} |

---

## 6. Action Plan

### Quick Wins (This Week)

1. [ ] {action}
2. [ ] {action}
3. [ ] {action}

### Short Term (This Month)

1. [ ] {action}
2. [ ] {action}
3. [ ] {action}

### Long Term (This Quarter)

1. [ ] {action}
2. [ ] {action}
3. [ ] {action}

---

**Report generated**: {timestamp}
**Auditor**: skill-security-checklist v1.0
**Confidence**: Overall {high/medium/low}

## Notes

- Replace all `{placeholder}` values with actual data from the detection scripts
- Use the references for severity levels and thresholds
- Ensure every checklist item has a pros/cons table
- Categorize all findings as Critical, Warning, or Info
