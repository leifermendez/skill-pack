#!/usr/bin/env bash
#
# validate-specs.sh
# Spec Product Validator — referenced by skill-spec-product
#
# Este script valida estructura de carpetas y contenido YAML.
# No compila codigo, no ejecuta tests, no realiza deploys.
#
# Usage:
#   From project root: bash references/validate-specs.sh
#   From anywhere:     bash /path/to/skill-spec-product/references/validate-specs.sh
#
# Validates the spec-product/ directory structure and YAML contents.
#
# Dependencies:
#   - python3  (required for YAML schema validation)
#   - yamllint (optional, for syntax linting)
#
# Exit codes:
#   0 = all specs valid or only warnings
#   1 = one or more errors found
#
# What it validates:
#   1. spec-product/ directory exists (creates if missing)
#   2. No stray files directly under spec-product/
#   3. Each subfolder follows feat-XXXX-dd-mm-yy-hh-mm/ format
#   4. Each subfolder contains exactly one file: feat-XXXX.yml
#   5. YAML is syntactically valid
#   6. YAML contains all required fields: id, type, as_a, i_want, so_that, product
#   7. story.id matches the folder ID
#   8. story.status is one of: draft|refined|ready|in-review|approved|done
#   9. metadata.created_at matches folder timestamp (dd-mm-yy-hh-mm)
#  10. metadata.updated_at format is dd-mm-yy-hh-mm (if present)
#  11. IDs are sequential with no gaps
#

set -euo pipefail

# Resolve script location so it works from any working directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SPEC_DIR="$PROJECT_ROOT/spec-product"

ERRORS=0
WARNINGS=0
SPECS_CHECKED=0

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
  ((ERRORS++)) || true
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
  ((WARNINGS++)) || true
}

log_ok() {
  echo -e "${GREEN}[OK]${NC} $1"
}

log_info() {
  echo -e "${CYAN}[INFO]${NC} $1"
}

# ── 1. Check python3 availability ────────────────────────────────────────────
HAS_PYTHON3=false
if command -v python3 &> /dev/null; then
  HAS_PYTHON3=true
fi

HAS_YAMLLINT=false
if command -v yamllint &> /dev/null; then
  HAS_YAMLLINT=true
fi

if [[ "$HAS_PYTHON3" == false ]]; then
  log_error "python3 is required but not installed. Install it to enable full YAML validation."
  echo "========================================"
  echo "Validation aborted (missing dependency)."
  exit 1
fi

log_info "python3 found. Full YAML schema validation enabled."
if [[ "$HAS_YAMLLINT" == true ]]; then
  log_info "yamllint found. Extra syntax linting enabled."
fi

# ── 2. Check spec-product/ exists, create if missing ─────────────────────────
if [[ ! -d "$SPEC_DIR" ]]; then
  log_warn "Directory '$SPEC_DIR' does not exist. Creating..."
  mkdir -p "$SPEC_DIR"
  log_ok "Created empty '$SPEC_DIR/' directory."
fi

# ── 3. Detect stray files directly under spec-product/ ───────────────────────
STRAY_FILES=$(find "$SPEC_DIR" -maxdepth 1 -type f 2>/dev/null || true)
if [[ -n "$STRAY_FILES" ]]; then
  while IFS= read -r f; do
    [[ -n "$f" ]] && log_warn "Stray file in spec-product/: $(basename "$f") — specs must live inside feat-XXXX-.../ folders."
  done <<< "$STRAY_FILES"
fi

# ── 4. Find all feat-* directories (Bash 3.x compatible) ─────────────────────
FEAT_DIRS=()
while IFS= read -r dir; do
  [[ -n "$dir" ]] && FEAT_DIRS+=("$dir")
done < <(find "$SPEC_DIR" -maxdepth 1 -mindepth 1 -type d | sort)

if [[ ${#FEAT_DIRS[@]} -eq 0 ]]; then
  log_info "No spec folders found in '$SPEC_DIR/'. Ready for new specs."
  echo "========================================"
  echo "Validation complete: 0 specs, 0 errors, 0 warnings."
  exit 0
fi

log_info "Found ${#FEAT_DIRS[@]} spec folder(s). Validating..."
echo ""

# ── 5. Validate each folder ─────────────────────────────────────────────────
for DIR in "${FEAT_DIRS[@]}"; do
  BASENAME=$(basename "$DIR")

  # 5a. Naming convention: feat-XXXX-dd-mm-yy-hh-mm
  if [[ ! "$BASENAME" =~ ^feat-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
    log_error "Folder '$BASENAME' does not match 'feat-XXXX-dd-mm-yy-hh-mm' format."
    continue
  fi

  # Extract parts
  FEAT_ID=$(echo "$BASENAME" | cut -d'-' -f1,2)        # feat-0001
  TS_DATE=$(echo "$BASENAME" | cut -d'-' -f3-8)        # dd-mm-yy-hh-mm
  EXPECTED_FILE="${FEAT_ID}.yml"

  # 5b. Check exactly one file inside (and no subdirectories)
  SUBDIRS=$(find "$DIR" -mindepth 1 -type d | wc -l | tr -d ' ')
  if [[ "$SUBDIRS" -gt 0 ]]; then
    log_warn "Folder '$BASENAME' contains $SUBDIRS unexpected subdirectory(ies)."
  fi

  FILE_COUNT=$(find "$DIR" -maxdepth 1 -type f | wc -l | tr -d ' ')
  if [[ "$FILE_COUNT" -eq 0 ]]; then
    log_error "Folder '$BASENAME' is empty. Expected exactly 1 file: $EXPECTED_FILE."
    continue
  fi
  if [[ "$FILE_COUNT" -ne 1 ]]; then
    log_error "Folder '$BASENAME' must contain exactly 1 file, found $FILE_COUNT."
    continue
  fi

  FILE_PATH=$(find "$DIR" -maxdepth 1 -type f | head -n1)
  FILE_NAME=$(basename "$FILE_PATH")

  # 5c. Filename must match feat-XXXX.yml
  if [[ "$FILE_NAME" != "$EXPECTED_FILE" ]]; then
    log_error "Folder '$BASENAME' contains '$FILE_NAME', expected '$EXPECTED_FILE'."
    continue
  fi

  # 5d. YAML syntax check (yamllint or python3)
  if [[ "$HAS_YAMLLINT" == true ]]; then
    if ! yamllint -d relaxed "$FILE_PATH" > /dev/null 2>&1; then
      log_warn "YAML syntax issues in '$FILE_NAME'. Run 'yamllint $FILE_PATH' for details."
    fi
  fi

  # Python3 always available here (checked earlier)
  if ! python3 -c "import yaml; yaml.safe_load(open('$FILE_PATH'))" 2>/dev/null; then
    log_error "Invalid YAML syntax in '$FILE_NAME'."
    continue
  fi

  # 5e. Validate required YAML fields via python3
  VALIDATION_RESULT=$(python3 -c "
import yaml, sys
try:
    data = yaml.safe_load(open('$FILE_PATH'))
    story = data.get('story', {})
    missing = []
    if not story.get('id'): missing.append('id')
    if not story.get('type'): missing.append('type')
    if not story.get('as_a'): missing.append('as_a')
    if not story.get('i_want'): missing.append('i_want')
    if not story.get('so_that'): missing.append('so_that')
    if not story.get('product'): missing.append('product')
    if not story.get('metadata', {}).get('created_at'): missing.append('metadata.created_at')

    if missing:
        print('MISSING:' + ','.join(missing))
    else:
        print('OK')
except Exception as e:
    print('PARSE_ERROR:' + str(e))
" 2>/dev/null || echo "PARSE_ERROR")

  if [[ "$VALIDATION_RESULT" == PARSE_ERROR* ]]; then
    log_error "Failed to parse YAML fields in '$FILE_NAME'."
    continue
  fi
  if [[ "$VALIDATION_RESULT" == MISSING* ]]; then
    MISSING_FIELDS=$(echo "$VALIDATION_RESULT" | sed 's/MISSING://')
    log_error "'$FILE_NAME' missing required fields: $MISSING_FIELDS"
    continue
  fi

  # 5f. ID in YAML matches folder ID
  YAML_ID=$(python3 -c "
import yaml
data = yaml.safe_load(open('$FILE_PATH'))
print(data.get('story', {}).get('id', 'MISSING'))
" 2>/dev/null || echo "MISSING")

  if [[ "$YAML_ID" != "$FEAT_ID" ]]; then
    log_error "YAML id='$YAML_ID' does not match folder '$FEAT_ID'."
    continue
  fi

  # 5g. Validate status against allowed values
  YAML_STATUS=$(python3 -c "
import yaml
data = yaml.safe_load(open('$FILE_PATH'))
print(data.get('story', {}).get('status', 'MISSING'))
" 2>/dev/null || echo "MISSING")

  if [[ "$YAML_STATUS" != "draft" && "$YAML_STATUS" != "refined" && "$YAML_STATUS" != "ready" && "$YAML_STATUS" != "in-review" && "$YAML_STATUS" != "approved" && "$YAML_STATUS" != "done" ]]; then
    log_warn "'$FILE_NAME' has invalid status='$YAML_STATUS'. Must be one of: draft|refined|ready|in-review|approved|done."
  fi

  # 5h. created_at matches folder timestamp
  CREATED_AT=$(python3 -c "
import yaml
data = yaml.safe_load(open('$FILE_PATH'))
print(data.get('story', {}).get('metadata', {}).get('created_at', 'MISSING'))
" 2>/dev/null || echo "MISSING")

  if [[ "$CREATED_AT" != "$TS_DATE" && "$CREATED_AT" != "dd-mm-yy-hh-mm" ]]; then
    log_warn "metadata.created_at='$CREATED_AT' does not match folder timestamp '$TS_DATE'."
  fi

  # 5i. updated_at format (if present)
  UPDATED_AT=$(python3 -c "
import yaml
data = yaml.safe_load(open('$FILE_PATH'))
print(data.get('story', {}).get('metadata', {}).get('updated_at', ''))
" 2>/dev/null || echo "")

  if [[ -n "$UPDATED_AT" && "$UPDATED_AT" != "dd-mm-yy-hh-mm" ]]; then
    if [[ ! "$UPDATED_AT" =~ ^[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
      log_warn "metadata.updated_at='$UPDATED_AT' does not match 'dd-mm-yy-hh-mm' format."
    fi
  fi

  log_ok "$BASENAME/ → $FILE_NAME (id=$YAML_ID, status=$YAML_STATUS)"
  ((SPECS_CHECKED++)) || true
done

# ── 6. Check for sequential IDs (no gaps) ──────────────────────────────────
IDS=()
while IFS= read -r id; do
  [[ -n "$id" ]] && IDS+=("$id")
done < <(for DIR in "${FEAT_DIRS[@]}"; do basename "$DIR" | cut -d'-' -f2; done | sort -n)

PREV=0
for ID in "${IDS[@]}"; do
  # Remove leading zeros for arithmetic
  ID_NUM=$((10#$ID))
  if [[ "$ID_NUM" -ne $((PREV + 1)) && "$PREV" -ne 0 ]]; then
    EXPECTED=$(printf "%04d" $((PREV + 1)))
    log_warn "Gap detected: expected feat-$EXPECTED, found feat-$ID."
  fi
  PREV=$ID_NUM
done

# ── 7. Summary ─────────────────────────────────────────────────────────────
echo ""
echo "========================================"
echo "Validation complete"
echo "  Specs checked: $SPECS_CHECKED"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"
echo "========================================"

if [[ "$ERRORS" -gt 0 ]]; then
  echo ""
  echo "Fix all errors before proceeding to the next phase."
  exit 1
fi

exit 0
