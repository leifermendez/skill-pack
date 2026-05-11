#!/usr/bin/env bash
set -euo pipefail

# aggregate-raw-data.sh
# Convenience orchestrator that runs the full audit toolchain and produces
# a single combined YAML document with all raw data.
# Outputs YAML to stdout and saves intermediates to /tmp/.
#
# Usage: bash aggregate-raw-data.sh <project_path> [--debug]
# --debug keeps intermediate files in /tmp/

PROJECT="${1:-.}"
DEBUG="${2:-}"

if [ "$DEBUG" = "--debug" ]; then
  KEEP_TMP=1
else
  KEEP_TMP=0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%s)
TMPDIR="/tmp/ddd-audit-${TIMESTAMP}"
mkdir -p "$TMPDIR"

# Step 1: Discover source
echo "# Running: discover-source.sh" >&2
"${SCRIPT_DIR}/discover-source.sh" "$PROJECT" > "$TMPDIR/01-source.yml"

SOURCE_ROOT=$(grep "^source_root:" "$TMPDIR/01-source.yml" | sed 's/^source_root: //')
if [ -z "$SOURCE_ROOT" ] || [ ! -d "$SOURCE_ROOT" ]; then
  echo "Error: Could not detect source root" >&2
  exit 1
fi

# Step 2: Discover layers
echo "# Running: discover-layers.sh" >&2
"${SCRIPT_DIR}/discover-layers.sh" "$SOURCE_ROOT" > "$TMPDIR/02-layers.yml"

# Step 3: Classify files
echo "# Running: classify-files.sh" >&2
"${SCRIPT_DIR}/classify-files.sh" "$SOURCE_ROOT" > "$TMPDIR/03-files.yml"

# Step 4: Extract imports
echo "# Running: extract-imports.sh" >&2
"${SCRIPT_DIR}/extract-imports.sh" "$TMPDIR/03-files.yml" > "$TMPDIR/04-imports.yml"

# Step 5: Validate dependencies
echo "# Running: validate-dependencies.sh" >&2
"${SCRIPT_DIR}/validate-dependencies.sh" "$TMPDIR/04-imports.yml" "$TMPDIR/02-layers.yml" > "$TMPDIR/05-violations.yml"

# Step 6: Validate naming
echo "# Running: validate-naming.sh" >&2
"${SCRIPT_DIR}/validate-naming.sh" "$TMPDIR/03-files.yml" > "$TMPDIR/06-naming.yml"

# Step 7: Detect logic leaks
echo "# Running: detect-logic-leaks.sh" >&2
"${SCRIPT_DIR}/detect-logic-leaks.sh" "$TMPDIR/03-files.yml" > "$TMPDIR/07-logic.yml"

# Combine into a single YAML document
echo "# Combined raw audit data" > "$TMPDIR/aggregate.yml"
echo "---" >> "$TMPDIR/aggregate.yml"
echo "project_path: $PROJECT" >> "$TMPDIR/aggregate.yml"
echo "source_root: $SOURCE_ROOT" >> "$TMPDIR/aggregate.yml"
echo "audit_timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$TMPDIR/aggregate.yml"
echo "" >> "$TMPDIR/aggregate.yml"

for f in 01-source 02-layers 03-files 04-imports 05-violations 06-naming 07-logic; do
  echo "# ${f}" >> "$TMPDIR/aggregate.yml"
  cat "$TMPDIR/${f}.yml" >> "$TMPDIR/aggregate.yml"
  echo "" >> "$TMPDIR/aggregate.yml"
done

cat "$TMPDIR/aggregate.yml"

if [ "$KEEP_TMP" -eq 1 ]; then
  echo "# Debug: intermediates kept in $TMPDIR" >&2
else
  rm -rf "$TMPDIR"
fi
