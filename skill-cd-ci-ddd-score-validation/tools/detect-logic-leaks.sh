#!/usr/bin/env bash
set -euo pipefail

# detect-logic-leaks.sh
# Heuristic detection of business logic keywords in Interface/Controller files.
# Reads a classify-files YAML.
# Outputs YAML logic leaks to stdout.
#
# Usage: bash detect-logic-leaks.sh <classified_files.yml>

INPUT_FILE="${1:-}"
if [ -z "$INPUT_FILE" ] || [ ! -f "$INPUT_FILE" ]; then
  echo "Usage: $0 <classified_files.yml>" >&2
  exit 1
fi

# Keywords that suggest business logic
KEYWORDS="calculate|validate|compute|process|transform|business|rule|apply.*discount|apply.*tax|fee|commission|tax|discount|interest|rate|if.*amount|if.*balance|if.*total|determine.*price|determine.*cost|check.*eligibility|approve.*request|reject.*request|grant.*permission|deduct|charge|refund|penalty|bonus|credit|debit|invoice|billing|subscription|prorate|escalate|workflow|state.*machine|decision.*tree"

echo "logic_leaks:"

path=""
layer=""
source_root=""

while IFS= read -r line; do
  if echo "$line" | grep -qE "^source_root:"; then
    source_root=$(echo "$line" | sed -E 's/^[[:space:]]*source_root: //')
  elif echo "$line" | grep -qE "^\s+- path:"; then
    path=$(echo "$line" | sed -E 's/^[[:space:]]*- path: //')
    layer=""
  elif echo "$line" | grep -qE "^\s+layer:"; then
    layer=$(echo "$line" | sed -E 's/^[[:space:]]*layer: //')

    if [ -n "$path" ] && [ -n "$layer" ]; then
      if [ "$layer" = "Interface" ] || [ "$layer" = "Infrastructure" ]; then
        abs=""
        if [ -f "$path" ]; then
          abs="$path"
        elif [ -n "$source_root" ] && [ -f "$source_root/$path" ]; then
          abs="$source_root/$path"
        fi
        if [ -n "$abs" ] && [ -f "$abs" ]; then
          # Search for keywords in the file
          matches=$(grep -nEi "($KEYWORDS)" "$abs" 2>/dev/null || true)
          if [ -n "$matches" ]; then
            # Take first match only to keep output manageable
            first_match=$(echo "$matches" | head -n 1)
            keyword_found=$(echo "$first_match" | grep -oEi "($KEYWORDS)" | head -n 1 | tr '[:upper:]' '[:lower:]')
            context_line=$(echo "$first_match" | sed 's/^[0-9]*://' | sed 's/^ *//;s/ *$//' | sed 's/"/\\"/g')

            severity="high"
            if [ "$layer" = "Infrastructure" ]; then
              severity="medium"
            fi

            echo "  - file: $path"
            echo "    layer: $layer"
            echo "    keyword_found: $keyword_found"
            echo "    context_line: \"$context_line\""
            echo "    severity: $severity"
            if [ "$layer" = "Interface" ]; then
              echo "    suggestion: \"Move business logic from controller/handler to a Domain Service or Application Use Case.\""
            else
              echo "    suggestion: \"Move business logic from Infrastructure service to Domain or Application layer.\""
            fi
          fi
        fi
      fi
      path=""
      layer=""
    fi
  fi
done < "$INPUT_FILE"
