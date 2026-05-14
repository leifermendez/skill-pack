#!/usr/bin/env bash
set -euo pipefail

# get-diff.sh
# Extrae un diff de git y lo convierte a YAML estructurado.
# Por defecto: --staged (cambios en staging area).
# Salida: YAML con records de cada linea añadida/eliminada.

MODE="staged"
RANGE=""
HEAD_N="1"
PATCH_FILE=""

usage() {
  cat <<EOF
Usage: $0 [--staged | --range A..B | --head N | --file PATCHFILE]

Extrae un diff de git y lo convierte a YAML estructurado.
Por defecto: --staged (cambios en staging area).

Options:
  --staged        Diff de cambios staged
  --range A..B    Diff entre dos commits o ramas
  --head N        Diff de los ultimos N commits (HEAD~N..HEAD)
  --file F        Leer diff desde un archivo patch
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --staged) MODE="staged"; shift ;;
    --range) MODE="range"; RANGE="$2"; shift 2 ;;
    --head) MODE="head"; HEAD_N="$2"; shift 2 ;;
    --file) MODE="file"; PATCH_FILE="$2"; shift 2 ;;
    --help|-h) usage ;;
    *) echo "Opcion desconocida: $1" >&2; usage ;;
  esac
done

get_diff_content() {
  case "$MODE" in
    staged) git diff --cached --unified=0 ;;
    range) git diff "$RANGE" --unified=0 ;;
    head) git diff "HEAD~${HEAD_N}" HEAD --unified=0 ;;
    file) cat "$PATCH_FILE" ;;
  esac
}

DIFF_CONTENT=$(get_diff_content)

if [[ -z "$DIFF_CONTENT" ]]; then
  cat <<EOF
diff:
  mode: "$MODE"
  files_changed: 0
  lines_added: 0
  lines_removed: 0
  records: []
EOF
  exit 0
fi

TMP_RECORDS=$(mktemp)
TMP_FILES=$(mktemp)

lines_added=0
lines_removed=0
records=0

current_file=""
new_line_num=0
in_hunk=0

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" == diff\ --git* ]]; then
    rest="${line#* b/}"
    rest="${rest#\"}"
    rest="${rest%\"}"
    current_file="$rest"
    in_hunk=0
  elif [[ "$line" == @@* ]]; then
    range_info="${line#@@ }"
    range_info="${range_info% @@*}"
    plus_part="${range_info#*\+}"
    new_line_num="${plus_part%%,*}"
    in_hunk=1
  elif [[ "$in_hunk" -eq 1 ]]; then
    if [[ "$line" == +* && "$line" != "+++ "* ]]; then
      content="${line:1}"
      content="${content//\\/\\\\}"
      content="${content//\"/\\\"}"
      {
        echo "  - file: \"$current_file\""
        echo "    line_type: \"added\""
        echo "    line_number: $new_line_num"
        echo "    content: \"$content\""
      } >> "$TMP_RECORDS"
      ((new_line_num++)) || true
      ((lines_added++)) || true
      ((records++)) || true
      echo "$current_file" >> "$TMP_FILES"
    elif [[ "$line" == -* && "$line" != "--- "* ]]; then
      content="${line:1}"
      content="${content//\\/\\\\}"
      content="${content//\"/\\\"}"
      {
        echo "  - file: \"$current_file\""
        echo "    line_type: \"removed\""
        echo "    line_number: $new_line_num"
        echo "    content: \"$content\""
      } >> "$TMP_RECORDS"
      ((lines_removed++)) || true
      ((records++)) || true
      echo "$current_file" >> "$TMP_FILES"
    elif [[ "$line" == \ * ]]; then
      ((new_line_num++)) || true
    fi
  fi
done <<< "$DIFF_CONTENT"

files_changed=$(sort -u "$TMP_FILES" | wc -l | tr -d ' ')

echo "diff:"
echo "  mode: \"$MODE\""
echo "  files_changed: $files_changed"
echo "  lines_added: $lines_added"
echo "  lines_removed: $lines_removed"
echo "  records:"

cat "$TMP_RECORDS"

rm -f "$TMP_RECORDS" "$TMP_FILES"
