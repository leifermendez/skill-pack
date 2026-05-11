#!/usr/bin/env bash
set -euo pipefail

# discover-layers.sh
# Detects Clean Architecture / DDD layer folders inside a source root.
# Outputs YAML to stdout.
#
# Usage: bash discover-layers.sh <source_root>

SOURCE="${1:-}"
if [ -z "$SOURCE" ]; then
  echo "Usage: $0 <source_root>" >&2
  exit 1
fi

SOURCE="$(cd "$SOURCE" && pwd)"

# Map: canonical layer -> list of accepted folder names (lowercase)
detect_layer() {
  local parent="$1"
  local name_lower
  name_lower=$(echo "$2" | tr '[:upper:]' '[:lower:]')

  case "$name_lower" in
    domain|domains|core|entities|entity|model|models)
      echo "Domain"
      ;;
    application|applications|app|apps|services|service)
      # Distinguish: if it has subfolders like use-cases/, domain/, it's Application layer
      # If it only has routes/pages, it's likely Interface (NextJS app/)
      if [ -d "$parent/$2/use-cases" ] || [ -d "$parent/$2/usecases" ] || [ -d "$parent/$2/domain" ] || [ -d "$parent/$2/dtos" ]; then
        echo "Application"
      elif [ -d "$parent/$2/routes" ] || [ -d "$parent/$2/pages" ] || [ -d "$parent/$2/controllers" ] || [ -d "$parent/$2/api" ]; then
        echo "Interface"
      else
        # Ambiguous: default to Application if it has .ts/.js with service/usecase patterns
        local svc_count
        svc_count=$(find "$parent/$2" -maxdepth 1 -type f 2>/dev/null | grep -cE "\.(ts|js|java|py|go|php|cs)$" || true)
        if [ "${svc_count:-0}" -gt 0 ]; then
          echo "Application"
        else
          echo ""
        fi
      fi
      ;;
    usecases|use-cases|use_cases|uc|ucs|interactors|features|feature)
      echo "UseCases"
      ;;
    infrastructure|infra|infrastructures|adapter|adapters|persistence|persistences|db|database|databases|external|externals|data)
      echo "Infrastructure"
      ;;
    interface|interfaces|presenter|presenters|controller|controllers|api|apis|http|rest|web|cli|route|routes|router|routers|handler|handlers|middleware|middlewares|interceptor|interceptors|guard|guards)
      echo "Interface"
      ;;
    presentation|presentations|@presentation|@presentations|ui|view|views)
      echo "Presentation"
      ;;
    ports|port)
      echo "Application"
      ;;
    *)
      echo ""
      ;;
  esac
}

echo "source_root: $SOURCE"
echo "layers_detected:"

# We scan immediate subdirectories of SOURCE
for dir in "$SOURCE"/*/; do
  [ -d "$dir" ] || continue
  basename=$(basename "$dir")
  layer=$(detect_layer "$SOURCE" "$basename")
  if [ -n "$layer" ]; then
    file_count=$(find "$dir" -type f | wc -l | tr -d ' ')
    echo "  - name: $layer"
    echo "    path: $(realpath --relative-to="$SOURCE" "$dir" 2>/dev/null || echo "$basename")"
    echo "    file_count: $file_count"
  fi
done
