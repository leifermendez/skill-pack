#!/usr/bin/env bash
set -euo pipefail

# extract-imports.sh
# Extracts imports from classified source files.
# Reads a classify-files YAML from stdin or from a file argument.
# Outputs YAML to stdout.
#
# Usage: bash extract-imports.sh <classified_files.yml>
#   OR   cat classified_files.yml | bash extract-imports.sh

INPUT_FILE="${1:-}"

if [ -n "$INPUT_FILE" ] && [ -f "$INPUT_FILE" ]; then
  CONTENT=$(cat "$INPUT_FILE")
elif [ -n "$INPUT_FILE" ]; then
  echo "File not found: $INPUT_FILE" >&2
  exit 1
else
  CONTENT=$(cat)
fi

# Extract source_root if present
SOURCE_ROOT=$(echo "$CONTENT" | grep -m1 "^source_root:" | sed 's/^source_root: //')

# Helper: extract quoted string after a keyword
extract_quoted() {
  local raw="$1"
  local keyword="$2"
  echo "$raw" | awk -v kw="$keyword" '{
    for(i=1;i<=NF;i++) {
      if($i==kw && i<NF) {
        q=substr($(i+1),1,1)
        if(q=="\"" || q=="\047") {
          rest=substr($(i+1),2)
          n=index(rest,q)
          if(n>0) {
            print substr(rest,1,n-1)
            exit
          }
        }
      }
    }
  }'
}

echo "imports:"

# Extract all path: lines using a while loop to handle spaces
while IFS= read -r line; do
  file=$(echo "$line" | sed -E 's/^[[:space:]]*- path: //')
  [ -z "$file" ] && continue

  abs=""
  if [ -f "$file" ]; then
    abs="$file"
  elif [ -f "/$file" ]; then
    abs="/$file"
  elif [ -n "$SOURCE_ROOT" ] && [ -f "$SOURCE_ROOT/$file" ]; then
    abs="$SOURCE_ROOT/$file"
  fi

  [ -z "$abs" ] && continue
  [ ! -f "$abs" ] && continue

  lang="${abs##*.}"

  # Extract imports based on language
  case "$lang" in
    ts|tsx|js|jsx|mjs)
      while IFS= read -r rawline; do
        imported=$(extract_quoted "$rawline" "from")
        if [ -n "$imported" ]; then
          is_relative="false"
          if echo "$imported" | grep -qE "^\./|^\.\./"; then
            is_relative="true"
          fi
          is_type_only="false"
          if echo "$rawline" | grep -qE "import\s+type\s+"; then
            is_type_only="true"
          fi
          line_clean=$(echo "$rawline" | sed 's/"/\\"/g')
          echo "  - source_file: $file"
          echo "    imported_path: $imported"
          echo "    is_relative: $is_relative"
          echo "    is_type_only: $is_type_only"
          echo "    import_line: \"$line_clean\""
          echo "    language: typescript"
        fi
      done < <(grep -nE "import\s+.*\s+from\s+['\"].+['\"]" "$abs" 2>/dev/null)

      while IFS= read -r rawline; do
        imported=$(extract_quoted "$rawline" "require")
        if [ -n "$imported" ]; then
          is_relative="false"
          if echo "$imported" | grep -qE "^\./|^\.\./"; then
            is_relative="true"
          fi
          line_clean=$(echo "$rawline" | sed 's/"/\\"/g')
          echo "  - source_file: $file"
          echo "    imported_path: $imported"
          echo "    is_relative: $is_relative"
          echo "    import_line: \"$line_clean\""
          echo "    language: typescript"
        fi
      done < <(grep -nE "require\s*\(\s*['\"].+['\"]\s*\)" "$abs" 2>/dev/null)
      ;;
    java)
      while IFS= read -r rawline; do
        imported=$(echo "$rawline" | sed -nE "s/.*import\s+([^;]+);.*/\1/p")
        if [ -n "$imported" ]; then
          line_clean=$(echo "$rawline" | sed 's/"/\\"/g')
          echo "  - source_file: $file"
          echo "    imported_path: $imported"
          echo "    is_relative: false"
          echo "    import_line: \"$line_clean\""
          echo "    language: java"
        fi
      done < <(grep -nE "^\s*import\s+(.+);" "$abs" 2>/dev/null | grep -v "import static")
      ;;
    py)
      while IFS= read -r rawline; do
        imported=""
        if echo "$rawline" | grep -qE "from\s+(.+)\s+import"; then
          imported=$(echo "$rawline" | awk '{for(i=1;i<=NF;i++){if($i=="from"){print $(i+1);exit}}}')
        else
          imported=$(echo "$rawline" | awk '{for(i=1;i<=NF;i++){if($i=="import"){print $(i+1);exit}}}')
        fi
        if [ -n "$imported" ]; then
          is_relative="false"
          if echo "$imported" | grep -qE "^\.|^\./|^\.\./"; then
            is_relative="true"
          fi
          line_clean=$(echo "$rawline" | sed 's/"/\\"/g')
          echo "  - source_file: $file"
          echo "    imported_path: $imported"
          echo "    is_relative: $is_relative"
          echo "    import_line: \"$line_clean\""
          echo "    language: python"
        fi
      done < <(grep -nE "^\s*(from\s+(.+)\s+import|import\s+(.+))" "$abs" 2>/dev/null)
      ;;
    php)
      while IFS= read -r rawline; do
        imported=$(echo "$rawline" | sed -nE "s/.*use\s+([^;]+);.*/\1/p")
        if [ -n "$imported" ]; then
          line_clean=$(echo "$rawline" | sed 's/"/\\"/g')
          echo "  - source_file: $file"
          echo "    imported_path: $imported"
          echo "    is_relative: false"
          echo "    import_line: \"$line_clean\""
          echo "    language: php"
        fi
      done < <(grep -nE "^\s*use\s+(.+);" "$abs" 2>/dev/null)
      ;;
    go)
      while IFS= read -r rawline; do
        imported=$(extract_quoted "$rawline" "import")
        if [ -n "$imported" ]; then
          is_relative="false"
          if echo "$imported" | grep -qE "^\./|^\.\./"; then
            is_relative="true"
          fi
          line_clean=$(echo "$rawline" | sed 's/"/\\"/g')
          echo "  - source_file: $file"
          echo "    imported_path: $imported"
          echo "    is_relative: $is_relative"
          echo "    import_line: \"$line_clean\""
          echo "    language: go"
        fi
      done < <(grep -nE "^\s*import\s+\"(.+)\"" "$abs" 2>/dev/null)
      ;;
    cs)
      while IFS= read -r rawline; do
        imported=$(echo "$rawline" | sed -nE "s/.*using\s+([^;]+);.*/\1/p")
        if [ -n "$imported" ]; then
          line_clean=$(echo "$rawline" | sed 's/"/\\"/g')
          echo "  - source_file: $file"
          echo "    imported_path: $imported"
          echo "    is_relative: false"
          echo "    import_line: \"$line_clean\""
          echo "    language: csharp"
        fi
      done < <(grep -nE "^\s*using\s+(.+);" "$abs" 2>/dev/null)
      ;;
  esac
done < <(echo "$CONTENT" | grep -E '^\s+- path: ')
