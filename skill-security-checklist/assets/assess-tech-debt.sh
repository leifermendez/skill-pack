#!/bin/bash

# Assess technical debt in a codebase
# Usage: bash assess-tech-debt.sh <project_path>

PROJECT_PATH="${1:-.}"
PROJECT_NAME="$(basename "$PROJECT_PATH")"

# Output YAML header
echo "tech_debt:"
echo "  project: $PROJECT_NAME"
echo "  path: $PROJECT_PATH"
echo "  timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  assessments:"

# Counter for debt items
DEBT_COUNT=0
TOTAL_SCORE=0

# Check 1: TODO/FIXME/XXX comments
echo "    - id: todo_fixme"
echo "      name: TODO and FIXME Comments"
echo "      category: documentation"
echo "      findings:"

TODO_COUNT=$(grep -riE "TODO|FIXME|XXX|HACK|BUG|NOTE.*fix" "$PROJECT_PATH" \
  --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" --include="*.py" --include="*.go" --include="*.java" --include="*.rb" --include="*.php" --include="*.c" --include="*.cpp" --include="*.h" --include="*.cs" \
  --include="*.md" --include="*.txt" \
  -c 2>/dev/null | grep -vE "node_modules|vendor|\.git|dist|build|\.next|\.nuxt|coverage" | awk -F: '{sum+=$2} END {print sum+0}' || echo "0")

if [ "$TODO_COUNT" -gt 0 ]; then
  echo "      - type: todo_comments"
  echo "        count: $TODO_COUNT"
  echo "        description: Outstanding TODO/FIXME comments indicating incomplete work"
  echo "        severity: $(if [ "$TODO_COUNT" -gt 50 ]; then echo "high"; elif [ "$TODO_COUNT" -gt 20 ]; then echo "medium"; else echo "low"; fi)"
  echo "        recommendation: Review and resolve TODOs; convert critical ones to tickets"
  DEBT_COUNT=$((DEBT_COUNT + 1))
  TOTAL_SCORE=$((TOTAL_SCORE + TODO_COUNT))
fi

# Check 2: Missing tests
echo "    - id: test_coverage"
echo "      name: Test Coverage"
echo "      category: quality"
echo "      findings:"

TEST_FILES=$(find "$PROJECT_PATH" -maxdepth 4 -type f \( \
  -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" -o -name "*_spec.*" -o -name "test_*" -o -name "tests_*" \
  -o -path "*/tests/*" -o -path "*/test/*" -o -path "*/__tests__/*" \
  \) -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

SOURCE_FILES=$(find "$PROJECT_PATH" -type f \( \
  -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rb" -o -name "*.php" -o -name "*.c" -o -name "*.cpp" -o -name "*.cs" \
  \) -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" -not -name "*.test.*" -not -name "*.spec.*" -not -name "*_test.*" -not -name "*_spec.*" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

if [ "$SOURCE_FILES" -gt 0 ]; then
  TEST_RATIO=$(echo "scale=2; $TEST_FILES / $SOURCE_FILES" | bc 2>/dev/null || echo "0")
  echo "      - type: test_files"
  echo "        test_files: $TEST_FILES"
  echo "        source_files: $SOURCE_FILES"
  echo "        ratio: $TEST_RATIO"
  echo "        severity: $(if [ "$TEST_FILES" -eq 0 ]; then echo "high"; elif [ "$TEST_FILES" -lt $(echo "$SOURCE_FILES / 10" | bc) ]; then echo "medium"; else echo "low"; fi)"
  echo "        recommendation: Aim for at least 1 test file per 3-5 source files; add unit tests for critical paths"
  DEBT_COUNT=$((DEBT_COUNT + 1))
fi

# Check 3: Deprecated dependencies
echo "    - id: deprecated_deps"
echo "      name: Deprecated Dependencies"
echo "      category: dependencies"
echo "      findings:"

DEPRECATED_PATTERNS="deprecated|legacy|obsolete|unmaintained|abandoned|end-of-life|eol"

if [ -f "$PROJECT_PATH/package.json" ]; then
  DEPRECATED_DEPS=$(grep -iE "$DEPRECATED_PATTERNS" "$PROJECT_PATH/package.json" -c 2>/dev/null || echo "0")
  if [ "$DEPRECATED_DEPS" -gt 0 ]; then
    echo "      - type: deprecated_in_package_json"
    echo "        count: $DEPRECATED_DEPS"
    echo "        description: package.json contains deprecated dependency markers"
    echo "        severity: medium"
    echo "        recommendation: Audit dependencies and replace deprecated packages"
    DEBT_COUNT=$((DEBT_COUNT + 1))
  fi
fi

if [ -f "$PROJECT_PATH/requirements.txt" ]; then
  echo "      - type: python_requirements"
  echo "        description: Python requirements.txt found - check for outdated packages"
  echo "        severity: low"
  echo "        recommendation: Run pip list --outdated or use pip-audit"
  DEBT_COUNT=$((DEBT_COUNT + 1))
fi

# Check 4: Documentation gaps
echo "    - id: documentation"
echo "      name: Documentation"
echo "      category: documentation"
echo "      findings:"

README_EXISTS="false"
CONTRIBUTING_EXISTS="false"
API_DOCS_EXISTS="false"
ARCHITECTURE_DOC_EXISTS="false"

[ -f "$PROJECT_PATH/README.md" ] && README_EXISTS="true"
[ -f "$PROJECT_PATH/CONTRIBUTING.md" ] && CONTRIBUTING_EXISTS="true"
[ -f "$PROJECT_PATH/API.md" ] || [ -f "$PROJECT_PATH/docs/api.md" ] || [ -f "$PROJECT_PATH/openapi.yaml" ] || [ -f "$PROJECT_PATH/openapi.json" ] || [ -f "$PROJECT_PATH/swagger.yaml" ] || [ -f "$PROJECT_PATH/swagger.json" ] && API_DOCS_EXISTS="true"
[ -f "$PROJECT_PATH/ARCHITECTURE.md" ] || [ -f "$PROJECT_PATH/docs/architecture.md" ] || [ -f "$PROJECT_PATH/adr" ] && ARCHITECTURE_DOC_EXISTS="true"

echo "      - type: readme"
echo "        exists: $README_EXISTS"
echo "        severity: $(if [ "$README_EXISTS" = "false" ]; then echo "high"; else echo "low"; fi)"
echo "        recommendation: $(if [ "$README_EXISTS" = "false" ]; then echo "Add README.md with setup, usage, and contribution info"; else echo "Keep README up to date"; fi)"

echo "      - type: contributing_guide"
echo "        exists: $CONTRIBUTING_EXISTS"
echo "        severity: $(if [ "$CONTRIBUTING_EXISTS" = "false" ]; then echo "medium"; else echo "low"; fi)"
echo "        recommendation: $(if [ "$CONTRIBUTING_EXISTS" = "false" ]; then echo "Add CONTRIBUTING.md for team onboarding"; else echo "Keep contributing guide current"; fi)"

echo "      - type: api_documentation"
echo "        exists: $API_DOCS_EXISTS"
echo "        severity: $(if [ "$API_DOCS_EXISTS" = "false" ]; then echo "medium"; else echo "low"; fi)"
echo "        recommendation: $(if [ "$API_DOCS_EXISTS" = "false" ]; then echo "Add API docs (OpenAPI/Swagger)"; else echo "Keep API docs in sync with code"; fi)"

echo "      - type: architecture_documentation"
echo "        exists: $ARCHITECTURE_DOC_EXISTS"
echo "        severity: $(if [ "$ARCHITECTURE_DOC_EXISTS" = "false" ]; then echo "medium"; else echo "low"; fi)"
echo "        recommendation: $(if [ "$ARCHITECTURE_DOC_EXISTS" = "false" ]; then echo "Document architecture decisions (ADRs)"; else echo "Maintain ADRs"; fi)"

DEBT_COUNT=$((DEBT_COUNT + 4))

# Check 5: Legacy / outdated code patterns
echo "    - id: legacy_patterns"
echo "      name: Legacy Code Patterns"
echo "      category: code_quality"
echo "      findings:"

LEGACY_PATTERNS="var\s+|jQuery|angular\.js|backbone|underscore|moment\(|require\(|exports\[|module\.exports|promisify|async\.js|callback\(null|cb\(null|\.then\(|\.catch\(|new\s+Promise"

LEGACY_FILES=$(grep -riE "($LEGACY_PATTERNS)" "$PROJECT_PATH" \
  --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" \
  -l 2>/dev/null | grep -vE "node_modules|vendor|\.git|dist|build" | head -10 || true)

if [ -n "$LEGACY_FILES" ]; then
  echo "      - type: legacy_patterns"
  echo "        description: Files using older patterns (var, callbacks, old libraries)"
  echo "        files:"
  for file in $LEGACY_FILES; do
    echo "          - $(realpath --relative-to="$PROJECT_PATH" "$file" 2>/dev/null || echo "$file")"
  done
  echo "        severity: low"
  echo "        recommendation: Modernize to ES6+ or current language standards"
  DEBT_COUNT=$((DEBT_COUNT + 1))
fi

# Check 6: Mixed naming conventions
echo "    - id: naming_conventions"
echo "      name: Naming Conventions"
echo "      category: consistency"
echo "      findings:"

CAMEL_CASE=$(find "$PROJECT_PATH" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" -not -name "*.d.ts" 2>/dev/null | grep -cE "[A-Z]" || echo "0")
SNAKE_CASE=$(find "$PROJECT_PATH" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" -not -name "*.d.ts" 2>/dev/null | grep -cE "_" || echo "0")
KEBAB_CASE=$(find "$PROJECT_PATH" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" -not -name "*.d.ts" 2>/dev/null | grep -cE "\-" || echo "0")

if [ "$CAMEL_CASE" -gt 0 ] && [ "$SNAKE_CASE" -gt 0 ]; then
  echo "      - type: mixed_naming"
  echo "        description: Both camelCase and snake_case filenames detected"
  echo "        camel_case_files: $CAMEL_CASE"
  echo "        snake_case_files: $SNAKE_CASE"
  echo "        kebab_case_files: $KEBAB_CASE"
  echo "        severity: low"
  echo "        recommendation: Standardize on one naming convention (e.g., camelCase for JS/TS)"
  DEBT_COUNT=$((DEBT_COUNT + 1))
fi

# Check 7: Missing type safety
echo "    - id: type_safety"
echo "      name: Type Safety"
echo "      category: quality"
echo "      findings:"

JS_FILES=$(find "$PROJECT_PATH" -type f \( -name "*.js" -o -name "*.jsx" \) -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
TS_FILES=$(find "$PROJECT_PATH" -type f \( -name "*.ts" -o -name "*.tsx" \) -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

if [ "$JS_FILES" -gt 0 ] && [ "$TS_FILES" -eq 0 ]; then
  echo "      - type: no_typescript"
  echo "        description: JavaScript files found but no TypeScript"
  echo "        js_files: $JS_FILES"
  echo "        severity: medium"
  echo "        recommendation: Consider migrating to TypeScript for type safety and better tooling"
  DEBT_COUNT=$((DEBT_COUNT + 1))
fi

# Check 8: Unused / dead code
echo "    - id: dead_code"
echo "      name: Dead Code"
echo "      category: maintenance"
echo "      findings:"

UNUSED_PATTERNS="console\.log|debugger|alert\(|print\(|fmt\.Println|System\.out\.print"

UNUSED_FILES=$(grep -riE "($UNUSED_PATTERNS)" "$PROJECT_PATH" \
  --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" --include="*.py" --include="*.go" --include="*.java" --include="*.rb" --include="*.php" --include="*.c" --include="*.cpp" --include="*.cs" \
  -l 2>/dev/null | grep -vE "node_modules|vendor|\.git|dist|build" | head -10 || true)

if [ -n "$UNUSED_FILES" ]; then
  echo "      - type: debug_statements"
  echo "        description: Debug statements found in source code"
  echo "        files:"
  for file in $UNUSED_FILES; do
    echo "          - $(realpath --relative-to="$PROJECT_PATH" "$file" 2>/dev/null || echo "$file")"
  done
  echo "        severity: low"
  echo "        recommendation: Remove debug statements or use a logging library with levels"
  DEBT_COUNT=$((DEBT_COUNT + 1))
fi

# Summary
echo "  summary:"
echo "    total_debt_items: $DEBT_COUNT"
echo "    debt_score: $(if [ $DEBT_COUNT -gt 10 ]; then echo "high"; elif [ $DEBT_COUNT -gt 5 ]; then echo "medium"; else echo "low"; fi)"
echo "    prioritized_actions:"
echo "      - "Fix TODO/FIXME comments and convert to tickets""
echo "      - "Add test coverage for critical business logic""
echo "      - "Update deprecated dependencies""
echo "      - "Standardize naming conventions""
echo "      - "Add documentation (README, API docs, ADRs)""
