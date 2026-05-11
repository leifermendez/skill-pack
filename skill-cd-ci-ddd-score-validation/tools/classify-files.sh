#!/usr/bin/env bash
set -euo pipefail

# classify-files.sh
# Classifies every source file under a source root by layer and responsibility type.
# Outputs YAML to stdout.
#
# Usage: bash classify-files.sh <source_root>

SOURCE="${1:-}"
if [ -z "$SOURCE" ]; then
  echo "Usage: $0 <source_root>" >&2
  exit 1
fi

SOURCE="$(cd "$SOURCE" && pwd)"

SOURCE_EXTS="ts|tsx|js|jsx|mjs|java|py|go|php|cs"

get_language() {
  local file="$1"
  local ext="${file##*.}"
  case "$ext" in
    ts|tsx) echo "typescript" ;;
    js|jsx|mjs) echo "javascript" ;;
    java) echo "java" ;;
    py) echo "python" ;;
    go) echo "go" ;;
    php) echo "php" ;;
    cs) echo "csharp" ;;
    *) echo "unknown" ;;
  esac
}

get_layer_from_path() {
  local path_lower
  path_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case "$path_lower" in
    */domain/*|*/domains/*|*/core/*|*/entities/*|*/entity/*|*/model/*|*/models/*)
      echo "Domain"
      ;;
    */usecases/*|*/use-cases/*|*/use_cases/*|*/uc/*|*/ucs/*|*/interactors/*|*/features/*|*/feature/*)
      echo "UseCases"
      ;;
    */application/*|*/applications/*|*/app/*|*/apps/*|*/services/*|*/service/*|*/ports/*)
      # Distinguish app/ as Interface only if it looks like presentation
      if echo "$path_lower" | grep -qE "(route|page|controller|handler|view|ui|api|http|web|cli|presentation|interface|middleware|interceptor|guard)"; then
        echo "Interface"
      else
        echo "Application"
      fi
      ;;
    */infrastructure/*|*/infra/*|*/infrastructures/*|*/adapter/*|*/adapters/*|*/persistence/*|*/persistences/*|*/db/*|*/database/*|*/databases/*|*/external/*|*/externals/*|*/data/*)
      echo "Infrastructure"
      ;;
    */services/*|*/service/*|*/@services/*|*/@service/*|services/*|service/*|@services/*|@service/*)
      # @services is not a standard Clean Architecture layer.
      # Heuristic: if it contains concrete external adapters (Mail, Stripe, HTTP), classify as Infrastructure.
      # If it contains orchestration logic (FindUserService, ProcessOrderService), classify as Application.
      # Default to Infrastructure because most @services are concrete implementations.
      echo "Infrastructure"
      ;;
    */interface/*|*/interfaces/*|*/presentation/*|*/presentations/*|*/presenter/*|*/presenters/*|*/controller/*|*/controllers/*|*/api/*|*/apis/*|*/http/*|*/rest/*|*/web/*|*/ui/*|*/cli/*|*/view/*|*/views/*|*/route/*|*/routes/*|*/router/*|*/routers/*|*/handler/*|*/handlers/*|*/middleware/*|*/middlewares/*|*/interceptor/*|*/interceptors/*|*/guard/*|*/guards/*|interface/*|interfaces/*|presentation/*|presentations/*|controller/*|controllers/*|api/*|apis/*|http/*|rest/*|web/*|ui/*|cli/*|view/*|views/*|route/*|routes/*|router/*|routers/*|handler/*|handlers/*|middleware/*|middlewares/*|interceptor/*|interceptors/*|guard/*|guards/*)
      echo "Interface"
      ;;
    *)
      echo "Unknown"
      ;;
  esac
}

get_type_from_filename() {
  local name_lower
  name_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case "$name_lower" in
    *.entity.*|*.model.*) echo "entity" ;;
    *.vo.*|*.value.*|*.value-object.*) echo "value-object" ;;
    *.repository.interface.*|*.repo.interface.*|*.port.*) echo "repository-interface" ;;
    *.repository.*|*.repo.*)
      if echo "$name_lower" | grep -qE "interface|port|abstract"; then
        echo "repository-interface"
      else
        echo "repository-impl"
      fi
      ;;
    *.use-case.*|*.usecase.*|*.uc.*|*.interactor.*) echo "use-case" ;;
    *.dto.*|*.request.*|*.response.*|*.command.*|*.query.*) echo "dto" ;;
    *.controller.*|*.handler.*|*.route.*|*.router.*) echo "controller" ;;
    *.domain.service.*|*.domain-service.*) echo "service-domain" ;;
    *.service.*) echo "service-infra" ;;
    *.mapper.*|*.transform.*) echo "mapper" ;;
    *.config.*|*.configuration.*|*.env.*) echo "config" ;;
    *.middleware.*|*.interceptor.*|*.guard.*) echo "middleware" ;;
    *.adapter.*) echo "adapter" ;;
    *.event.*|*.events.*|*.domain-event.*) echo "event" ;;
    *) echo "generic" ;;
  esac
}

echo "source_root: $SOURCE"
echo "files:"

# Find all source files
while IFS= read -r -d '' file; do
  rel="${file#$SOURCE/}"
  lang=$(get_language "$file")
  layer=$(get_layer_from_path "$rel")
  base=$(basename "$file")
  type=$(get_type_from_filename "$base")

  echo "  - path: $rel"
  echo "    layer: $layer"
  echo "    language: $lang"
  echo "    type: $type"
  echo "    basename: $base"
done < <(find "$SOURCE" -type f | grep -E "\.($SOURCE_EXTS)$" | sort | tr '\n' '\0')
