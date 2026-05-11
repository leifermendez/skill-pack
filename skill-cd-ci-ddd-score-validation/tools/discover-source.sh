#!/usr/bin/env bash
set -euo pipefail

# discover-source.sh
# Detects the main source folder in a project.
# Outputs YAML to stdout.
#
# Usage: bash discover-source.sh [project_path]
# Default project_path: current directory

PROJECT="${1:-.}"
PROJECT="$(cd "$PROJECT" && pwd)"

# Extensions that count as source code
SOURCE_EXTS="ts|tsx|js|jsx|mjs|java|py|go|php|cs"

count_source_files() {
  local dir="$1"
  if [ -d "$dir" ]; then
    local cnt
    cnt=$(find "$dir" -maxdepth 3 -type f 2>/dev/null | grep -cE "\.($SOURCE_EXTS)$" || true)
    echo "${cnt:-0}"
  else
    echo 0
  fi
}

get_languages() {
  local dir="$1"
  local langs=""
  if [ -d "$dir" ]; then
    for ext in ts tsx js jsx mjs java py go php cs; do
      local count
      count=$(find "$dir" -maxdepth 3 -type f -name "*.$ext" | wc -l | tr -d ' ')
      if [ "$count" -gt 0 ]; then
        case "$ext" in
          ts|tsx) langs="${langs}typescript " ;;
          js|jsx|mjs) langs="${langs}javascript " ;;
          java) langs="${langs}java " ;;
          py) langs="${langs}python " ;;
          go) langs="${langs}go " ;;
          php) langs="${langs}php " ;;
          cs) langs="${langs}csharp " ;;
        esac
      fi
    done
  fi
  echo "$langs" | sed 's/ $//'
}

# Candidate directories
CANDIDATES=(
  "src"
  "source"
  "app"
  "lib"
  "src/main/java"
  "src/app"
)

# Add monorepo packages
if [ -d "$PROJECT/packages" ]; then
  for pkg in "$PROJECT/packages"/*/src; do
    if [ -d "$pkg" ]; then
      CANDIDATES+=("${pkg#$PROJECT/}")
    fi
  done
fi

# YAML output
echo "project_path: $PROJECT"
echo "candidates:"

BEST_DIR=""
BEST_COUNT=0
BEST_NAME=""

for rel in "${CANDIDATES[@]}"; do
  full="$PROJECT/$rel"
  count=$(count_source_files "$full")
  langs=$(get_languages "$full")
  echo "  - path: $rel"
  echo "    file_count: $count"
  if [ -n "$langs" ]; then
    echo "    languages:"
    for l in $langs; do
      echo "      - $l"
    done
  else
    echo "    languages: []"
  fi

  if [ "$count" -gt "$BEST_COUNT" ]; then
    BEST_COUNT=$count
    BEST_DIR="$full"
    BEST_NAME="$rel"
  fi
done

# Also consider root if it has source files directly
root_count=0
if [ -n "$(find "$PROJECT" -maxdepth 1 -type f 2>/dev/null | head -n 1)" ]; then
  root_count=$(find "$PROJECT" -maxdepth 1 -type f 2>/dev/null | grep -cE "\.($SOURCE_EXTS)$" || true)
fi
if [ "${root_count:-0}" -gt "$BEST_COUNT" ]; then
  BEST_COUNT=$root_count
  BEST_DIR="$PROJECT"
  BEST_NAME="."
fi

if [ -n "$BEST_DIR" ]; then
  echo "source_root: $BEST_DIR"
  echo "selected: $BEST_NAME"
  echo "selected_reason: highest file count ($BEST_COUNT)"
else
  echo "source_root: $PROJECT"
  echo "selected: ."
  echo "selected_reason: fallback to project root"
fi
