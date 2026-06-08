#!/bin/bash

# Generate a comprehensive audit report
# Usage: bash generate-audit-report.sh <project_path>

PROJECT_PATH="${1:-.}"
PROJECT_NAME="$(basename "$PROJECT_PATH")"
SCRIPT_DIR="$(dirname "$0")"

# Ensure project path exists
if [ ! -d "$PROJECT_PATH" ]; then
  echo "Error: Project path '$PROJECT_PATH' not found" >&2
  exit 1
fi

# Use printf for consistent formatting
printf '%s\n' '---'
printf '%s\n' "# Audit Report: $PROJECT_NAME"
printf '%s\n' ''
printf '%s\n' "**Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '%s\n' "**Auditor:** skill-security-checklist v1.0"
printf '%s\n' "**Path:** $(realpath "$PROJECT_PATH" 2>/dev/null || echo "$PROJECT_PATH")"
printf '%s\n' ''

# Run all phase scripts and collect outputs
printf '%s\n' '## Phase 1: Stack Detection'
printf '%s\n' ''

if [ -f "$SCRIPT_DIR/detect-stack.sh" ]; then
  printf '%s\n' '### Technology Stack'
  printf '%s\n' '```yaml'
  bash "$SCRIPT_DIR/detect-stack.sh" "$PROJECT_PATH" 2>/dev/null || printf '%s\n' '  error: Stack detection failed'
  printf '%s\n' '```'
  printf '%s\n' ''
fi

if [ -f "$SCRIPT_DIR/detect-architecture.sh" ]; then
  printf '%s\n' '### Architecture Pattern'
  printf '%s\n' '```yaml'
  bash "$SCRIPT_DIR/detect-architecture.sh" "$PROJECT_PATH" 2>/dev/null || printf '%s\n' '  error: Architecture detection failed'
  printf '%s\n' '```'
  printf '%s\n' ''
fi

if [ -f "$SCRIPT_DIR/detect-infrastructure.sh" ]; then
  printf '%s\n' '### Infrastructure & DevOps'
  printf '%s\n' '```yaml'
  bash "$SCRIPT_DIR/detect-infrastructure.sh" "$PROJECT_PATH" 2>/dev/null || printf '%s\n' '  error: Infrastructure detection failed'
  printf '%s\n' '```'
  printf '%s\n' ''
fi

printf '%s\n' '---'
printf '%s\n' ''
printf '%s\n' '## Phase 2: Code Quality Analysis'
printf '%s\n' ''

if [ -f "$SCRIPT_DIR/analyze-complexity.sh" ]; then
  printf '%s\n' '### Complexity & Code Smells'
  printf '%s\n' '```yaml'
  bash "$SCRIPT_DIR/analyze-complexity.sh" "$PROJECT_PATH" 2>/dev/null || printf '%s\n' '  error: Complexity analysis failed'
  printf '%s\n' '```'
  printf '%s\n' ''
fi

if [ -f "$SCRIPT_DIR/detect-security-risks.sh" ]; then
  printf '%s\n' '### Security Risks'
  printf '%s\n' '```yaml'
  bash "$SCRIPT_DIR/detect-security-risks.sh" "$PROJECT_PATH" 2>/dev/null || printf '%s\n' '  error: Security scan failed'
  printf '%s\n' '```'
  printf '%s\n' ''
fi

if [ -f "$SCRIPT_DIR/assess-tech-debt.sh" ]; then
  printf '%s\n' '### Technical Debt'
  printf '%s\n' '```yaml'
  bash "$SCRIPT_DIR/assess-tech-debt.sh" "$PROJECT_PATH" 2>/dev/null || printf '%s\n' '  error: Tech debt assessment failed'
  printf '%s\n' '```'
  printf '%s\n' ''
fi

printf '%s\n' '---'
printf '%s\n' ''
printf '%s\n' '## Raw Data Summary'
printf '%s\n' ''
printf '%s\n' 'This report contains raw YAML data from all detection phases.'
printf '%s\n' 'The LLM should interpret this data and generate a structured markdown report with:'
printf '%s\n' ''
printf '%s\n' '1. **Executive Summary** - Overall health score, critical issues count'
printf '%s\n' '2. **Stack Overview** - Technologies with pros/cons tables'
printf '%s\n' '3. **Architecture Analysis** - Pattern detection with layer health scores'
printf '%s\n' '4. **Security Checklist** - Risks with severity, pros/cons, mitigation steps'
printf '%s\n' '5. **Code Quality** - Metrics with thresholds, status, pros/cons'
printf '%s\n' '6. **Technical Debt** - Prioritized backlog with effort estimates'
printf '%s\n' '7. **Action Plan** - Quick wins, short term, long term'
printf '%s\n' ''
printf '%s\n' '## Next Steps'
printf '%s\n' ''
printf '%s\n' '1. Review the raw data above for each phase'
printf '%s\n' '2. Generate the final AUDIT_REPORT.md with structured tables and recommendations'
printf '%s\n' '3. Prioritize critical and high-severity issues'
printf '%s\n' '4. Create tickets for actionable items'
