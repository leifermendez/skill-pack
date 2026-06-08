#!/bin/bash

# Detect security risks in a codebase
# Usage: bash detect-security-risks.sh <project_path>

PROJECT_PATH="${1:-.}"
PROJECT_NAME="$(basename "$PROJECT_PATH")"

# Output YAML header
echo "security_scan:"
echo "  project: $PROJECT_NAME"
echo "  path: $PROJECT_PATH"
echo "  timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  checks:"

# Counter for checks
CHECK_COUNT=0

# Check 1: Hardcoded secrets and credentials
echo "    - id: secrets"
echo "      name: Hardcoded Secrets"
echo "      severity: critical"
echo "      findings:"

# Search for common secret patterns (case-insensitive)
SECRET_PATTERNS="password|secret|token|key|api_key|apikey|auth_token|access_token|private_key|credentials"
EXCLUDE_DIRS="node_modules|vendor|\.git|dist|build|\.next|\.nuxt|coverage|\.coverage"

# Find potential secrets in code files (not env files)
SECRET_FILES=$(grep -riE "($SECRET_PATTERNS)" "$PROJECT_PATH" \
  --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.rb" --include="*.php" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.xml" --include="*.properties" \
  --include="*.sql" --include="*.sh" --include="*.env*" \
  -l 2>/dev/null | grep -vE "($EXCLUDE_DIRS)" | head -20 || true)

if [ -n "$SECRET_FILES" ]; then
  echo "      - type: potential_secrets"
  echo "        description: Files containing possible hardcoded secrets"
  echo "        files:"
  for file in $SECRET_FILES; do
    echo "          - $(realpath --relative-to="$PROJECT_PATH" "$file" 2>/dev/null || echo "$file")"
  done
  echo "        recommendation: Move secrets to environment variables or a secret manager"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

# Check for .env files committed to repo
ENV_FILES=$(find "$PROJECT_PATH" -maxdepth 3 -name ".env*" -not -name ".env.example" -not -name ".env.template" -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" 2>/dev/null || true)

if [ -n "$ENV_FILES" ]; then
  echo "      - type: env_files_committed"
  echo "        description: Environment files found in repository"
  echo "        files:"
  for file in $ENV_FILES; do
    echo "          - $(realpath --relative-to="$PROJECT_PATH" "$file" 2>/dev/null || echo "$file")"
  done
  echo "        recommendation: Add .env files to .gitignore; use .env.example for templates"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

# Check 2: SQL Injection risks
echo "    - id: sql_injection"
echo "      name: SQL Injection Risks"
echo "      severity: high"
echo "      findings:"

SQL_INJECTION_PATTERNS="query\s*\(|execute\s*\(|raw\s*\(|\.query\(|\.execute\(|exec\s*\(|\$\{.*\}|format\s*\(|%\s*\(|f\"|f'"

RISK_FILES=$(grep -riE "($SQL_INJECTION_PATTERNS)" "$PROJECT_PATH" \
  --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.rb" --include="*.php" --include="*.sql" \
  -l 2>/dev/null | grep -vE "($EXCLUDE_DIRS)" | head -15 || true)

if [ -n "$RISK_FILES" ]; then
  echo "      - type: potential_sql_injection"
  echo "        description: Files with dynamic SQL or query building patterns"
  echo "        files:"
  for file in $RISK_FILES; do
    echo "          - $(realpath --relative-to="$PROJECT_PATH" "$file" 2>/dev/null || echo "$file")"
  done
  echo "        recommendation: Use parameterized queries or ORM; validate all inputs"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

# Check 3: XSS vulnerabilities
echo "    - id: xss"
echo "      name: Cross-Site Scripting (XSS)"
echo "      severity: high"
echo "      findings:"

XSS_PATTERNS="innerHTML|outerHTML|document\.write|eval\s*\(|dangerouslySetInnerHTML|v-html|ng-bind-html|\.html\(|\{\{\{.*\}\}\}"

XSS_FILES=$(grep -riE "($XSS_PATTERNS)" "$PROJECT_PATH" \
  --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" --include="*.vue" --include="*.html" --include="*.php" \
  -l 2>/dev/null | grep -vE "($EXCLUDE_DIRS)" | head -15 || true)

if [ -n "$XSS_FILES" ]; then
  echo "      - type: potential_xss"
  echo "        description: Files with potential XSS vectors (unescaped output, eval, innerHTML)"
  echo "        files:"
  for file in $XSS_FILES; do
    echo "          - $(realpath --relative-to="$PROJECT_PATH" "$file" 2>/dev/null || echo "$file")"
  done
  echo "        recommendation: Use framework auto-escaping; sanitize all user input; avoid innerHTML/eval"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

# Check 4: Insecure dependencies
echo "    - id: insecure_deps"
echo "      name: Insecure Dependencies"
echo "      severity: medium"
echo "      findings:"

# Check for known vulnerable package files
if [ -f "$PROJECT_PATH/package.json" ]; then
  echo "      - type: npm_project"
  echo "        description: Node.js project detected - run npm audit for vulnerability details"
  echo "        files:"
  echo "          - package.json"
  echo "        recommendation: Run npm audit and npm audit fix regularly"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

if [ -f "$PROJECT_PATH/requirements.txt" ] || [ -f "$PROJECT_PATH/Pipfile" ] || [ -f "$PROJECT_PATH/pyproject.toml" ]; then
  echo "      - type: python_project"
  echo "        description: Python project detected - check dependencies with safety or pip-audit"
  echo "        files:"
  [ -f "$PROJECT_PATH/requirements.txt" ] && echo "          - requirements.txt"
  [ -f "$PROJECT_PATH/Pipfile" ] && echo "          - Pipfile"
  [ -f "$PROJECT_PATH/pyproject.toml" ] && echo "          - pyproject.toml"
  echo "        recommendation: Run safety check or pip-audit for known vulnerabilities"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

if [ -f "$PROJECT_PATH/pom.xml" ] || [ -f "$PROJECT_PATH/build.gradle" ]; then
  echo "      - type: java_project"
  echo "        description: Java project detected - check dependencies with OWASP Dependency-Check"
  echo "        files:"
  [ -f "$PROJECT_PATH/pom.xml" ] && echo "          - pom.xml"
  [ -f "$PROJECT_PATH/build.gradle" ] && echo "          - build.gradle"
  echo "        recommendation: Run OWASP Dependency-Check or Snyk for Java vulnerabilities"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

# Check 5: Missing security headers / config
echo "    - id: security_config"
echo "      name: Security Configuration"
echo "      severity: medium"
echo "      findings:"

# Check for HTTPS/TLS configuration
if grep -riE "http://|ssl=false|verify_ssl=false|insecure|tls=false|disable.*security" "$PROJECT_PATH" \
  --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.properties" --include="*.xml" --include="*.conf" \
  -l 2>/dev/null | grep -vE "($EXCLUDE_DIRS)" | head -10 > /dev/null 2>&1; then
  echo "      - type: insecure_connections"
  echo "        description: Potential insecure connections or disabled TLS verification found"
  echo "        recommendation: Enforce HTTPS/TLS; never disable SSL verification in production"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

# Check for CORS wildcards
CORS_FILES=$(grep -riE "access-control-allow-origin.*\*|cors.*\*|origin.*\*" "$PROJECT_PATH" \
  --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.conf" \
  -l 2>/dev/null | grep -vE "($EXCLUDE_DIRS)" | head -10 || true)

if [ -n "$CORS_FILES" ]; then
  echo "      - type: wildcard_cors"
  echo "        description: CORS wildcard configuration detected"
  echo "        files:"
  for file in $CORS_FILES; do
    echo "          - $(realpath --relative-to="$PROJECT_PATH" "$file" 2>/dev/null || echo "$file")"
  done
  echo "        recommendation: Restrict CORS to specific origins; avoid wildcard in production"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

# Check 6: Authentication / Authorization patterns
echo "    - id: auth"
echo "      name: Authentication & Authorization"
echo "      severity: medium"
echo "      findings:"

# Check for JWT without proper validation
JWT_FILES=$(grep -riE "jwt|jsonwebtoken|passport|auth|oauth|sso|ldap" "$PROJECT_PATH" \
  --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.rb" --include="*.php" \
  -l 2>/dev/null | grep -vE "($EXCLUDE_DIRS)" | head -10 || true)

if [ -n "$JWT_FILES" ]; then
  echo "      - type: auth_detected"
  echo "        description: Authentication mechanisms detected - verify proper implementation"
  echo "        files:"
  for file in $JWT_FILES; do
    echo "          - $(realpath --relative-to="$PROJECT_PATH" "$file" 2>/dev/null || echo "$file")"
  done
  echo "        recommendation: Ensure JWT tokens are validated; use secure cookies; implement refresh token rotation"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

# Check 7: Input validation
echo "    - id: input_validation"
echo "      name: Input Validation"
echo "      severity: medium"
echo "      findings:"

# Check for raw user input usage
INPUT_FILES=$(grep -riE "req\.body|req\.query|req\.params|request\.GET|request\.POST|$_GET|$_POST|params\[|args\[|argv|process\.env" "$PROJECT_PATH" \
  --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.rb" --include="*.php" \
  -l 2>/dev/null | grep -vE "($EXCLUDE_DIRS)" | head -15 || true)

if [ -n "$INPUT_FILES" ]; then
  echo "      - type: user_input_usage"
  echo "        description: Files handling user input - verify validation and sanitization"
  echo "        files:"
  for file in $INPUT_FILES; do
    echo "          - $(realpath --relative-to="$PROJECT_PATH" "$file" 2>/dev/null || echo "$file")"
  done
  echo "        recommendation: Validate all inputs with schemas; sanitize before use; never trust user data"
  CHECK_COUNT=$((CHECK_COUNT + 1))
fi

# Summary
echo "  summary:"
echo "    total_checks: $CHECK_COUNT"
echo "    risk_level: $(if [ $CHECK_COUNT -gt 5 ]; then echo "high"; elif [ $CHECK_COUNT -gt 2 ]; then echo "medium"; else echo "low"; fi)"
echo "    scanned_files: $(find "$PROJECT_PATH" -type f \
  \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rb" -o -name "*.php" -o -name "*.sql" \) \
  -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" \
  | wc -l | tr -d ' ')"
