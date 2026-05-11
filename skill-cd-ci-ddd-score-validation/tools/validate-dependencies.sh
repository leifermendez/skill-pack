#!/usr/bin/env bash
set -euo pipefail

# validate-dependencies.sh
# Validates that imports respect the Clean Architecture dependency rule.
# Inputs: imports YAML file, layers YAML file.
# Outputs YAML violations to stdout.
#
# Usage: bash validate-dependencies.sh <imports.yml> <layers.yml>

IMPORTS_FILE="${1:-}"
LAYERS_FILE="${2:-}"

if [ -z "$IMPORTS_FILE" ] || [ -z "$LAYERS_FILE" ]; then
  echo "Usage: $0 <imports.yml> <layers.yml>" >&2
  exit 1
fi

# Determine layer from file path
guess_layer_from_path() {
  local path_lower
  path_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case "$path_lower" in
    */domain/*|*/domains/*|*/core/*|*/entities/*|*/entity/*|*/model/*|*/models/*)
      echo "Domain"
      ;;
    */usecases/*|*/use-cases/*|*/use_cases/*|*/uc/*|*/ucs/*|*/interactors/*|*/features/*|*/feature/*)
      echo "UseCases"
      ;;
    */application/*|*/applications/*|*/services/*|*/service/*|*/ports/*|*/dtos/*|*/dto/*)
      echo "Application"
      ;;
    */infrastructure/*|*/infra/*|*/infrastructures/*|*/adapter/*|*/adapters/*|*/persistence/*|*/persistences/*|*/db/*|*/database/*|*/databases/*|*/external/*|*/externals/*|*/data/*)
      echo "Infrastructure"
      ;;
    */interface/*|*/interfaces/*|*/presentation/*|*/presentations/*|*/presenter/*|*/presenters/*|*/controller/*|*/controllers/*|*/api/*|*/apis/*|*/http/*|*/rest/*|*/web/*|*/ui/*|*/cli/*|*/view/*|*/views/*|*/route/*|*/routes/*|*/router/*|*/routers/*|*/handler/*|*/handlers/*|*/middleware/*|*/middlewares/*|*/interceptor/*|*/interceptors/*|*/guard/*|*/guards/*)
      echo "Interface"
      ;;
    *)
      echo "Unknown"
      ;;
  esac
}

# Determine target layer from imported path
guess_target_layer() {
  local path_lower
  path_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case "$path_lower" in
    */domain/*|*/domains/*|*/core/*|*/entities/*|*/entity/*|*/model/*|*/models/*)
      echo "Domain"
      ;;
    */usecases/*|*/use-cases/*|*/use_cases/*|*/uc/*|*/ucs/*|*/interactors/*|*/features/*|*/feature/*)
      echo "UseCases"
      ;;
    */application/*|*/applications/*|*/services/*|*/service/*|*/ports/*|*/dtos/*|*/dto/*)
      echo "Application"
      ;;
    */infrastructure/*|*/infra/*|*/infrastructures/*|*/adapter/*|*/adapters/*|*/persistence/*|*/persistences/*|*/db/*|*/database/*|*/databases/*|*/external/*|*/externals/*|*/data/*)
      echo "Infrastructure"
      ;;
    */interface/*|*/interfaces/*|*/presentation/*|*/presentations/*|*/presenter/*|*/presenters/*|*/controller/*|*/controllers/*|*/api/*|*/apis/*|*/http/*|*/rest/*|*/web/*|*/ui/*|*/cli/*|*/view/*|*/views/*|*/route/*|*/routes/*|*/router/*|*/routers/*|*/handler/*|*/handlers/*|*/middleware/*|*/middlewares/*|*/interceptor/*|*/interceptors/*|*/guard/*|*/guards/*)
      echo "Interface"
      ;;
    *)
      echo "Unknown"
      ;;
  esac
}

# Dependency rule: returns true if import from source_layer to target_layer is allowed
is_allowed() {
  local src="$1"
  local tgt="$2"

  # Domain can only import Domain
  if [ "$src" = "Domain" ]; then
    [ "$tgt" = "Domain" ] && return 0 || return 1
  fi

  # Application can import Domain and Application (and UseCases if treated as Application)
  if [ "$src" = "Application" ]; then
    [ "$tgt" = "Domain" ] || [ "$tgt" = "Application" ] || [ "$tgt" = "UseCases" ] && return 0 || return 1
  fi

  # UseCases can import Domain, Application, UseCases
  if [ "$src" = "UseCases" ]; then
    [ "$tgt" = "Domain" ] || [ "$tgt" = "Application" ] || [ "$tgt" = "UseCases" ] && return 0 || return 1
  fi

  # Infrastructure can import Domain, Application, UseCases, Infrastructure
  if [ "$src" = "Infrastructure" ]; then
    [ "$tgt" = "Domain" ] || [ "$tgt" = "Application" ] || [ "$tgt" = "UseCases" ] || [ "$tgt" = "Infrastructure" ] && return 0 || return 1
  fi

  # Interface can import Application, UseCases, Interface
  if [ "$src" = "Interface" ]; then
    [ "$tgt" = "Application" ] || [ "$tgt" = "UseCases" ] || [ "$tgt" = "Interface" ] && return 0 || return 1
  fi

  return 1
}

echo "violations:"

# Parse imports YAML line by line
# We look for blocks starting with "  - source_file:"
# then read imported_path, is_relative, is_type_only
source_file=""
imported_path=""
is_relative=""
is_type_only=""

while IFS= read -r line; do
  if echo "$line" | grep -qE "^\s+- source_file:"; then
    source_file=$(echo "$line" | sed -E 's/^[[:space:]]*- source_file: //')
    imported_path=""
    is_relative=""
    is_type_only=""
  elif echo "$line" | grep -qE "^\s+imported_path:"; then
    imported_path=$(echo "$line" | sed -E 's/^[[:space:]]*imported_path: //')
  elif echo "$line" | grep -qE "^\s+is_relative:"; then
    is_relative=$(echo "$line" | sed -E 's/^[[:space:]]*is_relative: //')
  elif echo "$line" | grep -qE "^\s+is_type_only:"; then
    is_type_only=$(echo "$line" | sed -E 's/^[[:space:]]*is_type_only: //')
  elif echo "$line" | grep -qE "^\s+import_line:"; then
    # Trigger validation after the last field of the import block
    if [ -n "$source_file" ] && [ -n "$imported_path" ] && [ -n "$is_relative" ]; then
      src_layer=$(guess_layer_from_path "$source_file")
      tgt_layer=$(guess_target_layer "$imported_path")

      if [ "$src_layer" != "Unknown" ] && [ "$tgt_layer" != "Unknown" ]; then
        if ! is_allowed "$src_layer" "$tgt_layer"; then
          # Determine severity
          severity="high"
          if [ "$is_type_only" = "true" ]; then
            severity="low"
          elif [ "$src_layer" = "Domain" ]; then
            severity="critical"
          elif [ "$src_layer" = "Interface" ] && [ "$tgt_layer" = "Domain" ] || [ "$tgt_layer" = "Infrastructure" ]; then
            severity="critical"
          elif [ "$src_layer" = "Application" ] && [ "$tgt_layer" = "Infrastructure" ]; then
            severity="critical"
          fi

          # Determine rule code
          rule="DEPENDENCY_RULE_VIOLATION"
          if [ "$is_type_only" = "true" ]; then
            if [ "$src_layer" = "Domain" ]; then
              rule="DOMAIN_TYPE_IMPORT_INFRA"
            elif [ "$src_layer" = "Interface" ] && [ "$tgt_layer" = "Domain" ]; then
              rule="INTERFACE_TYPE_IMPORT_DOMAIN"
            elif [ "$src_layer" = "Interface" ] && [ "$tgt_layer" = "Infrastructure" ]; then
              rule="INTERFACE_TYPE_IMPORT_INFRA"
            elif [ "$src_layer" = "Application" ] && [ "$tgt_layer" = "Infrastructure" ]; then
              rule="APPLICATION_TYPE_IMPORT_INFRA"
            elif [ "$src_layer" = "Infrastructure" ] && [ "$tgt_layer" = "Interface" ]; then
              rule="INFRASTRUCTURE_TYPE_IMPORT_INTERFACE"
            fi
          else
            if [ "$src_layer" = "Domain" ]; then
              rule="DOMAIN_NO_EXTERNAL_DEPS"
            elif [ "$src_layer" = "Interface" ] && [ "$tgt_layer" = "Domain" ]; then
              rule="INTERFACE_NO_DOMAIN_ACCESS"
            elif [ "$src_layer" = "Interface" ] && [ "$tgt_layer" = "Infrastructure" ]; then
              rule="INTERFACE_NO_INFRA_ACCESS"
            elif [ "$src_layer" = "Application" ] && [ "$tgt_layer" = "Infrastructure" ]; then
              rule="APPLICATION_NO_INFRA_ACCESS"
            elif [ "$src_layer" = "Infrastructure" ] && [ "$tgt_layer" = "Interface" ]; then
              rule="INFRASTRUCTURE_NO_INTERFACE"
            fi
          fi

          # Suggestion
          suggestion=""
          case "$rule" in
            DOMAIN_NO_EXTERNAL_DEPS|DOMAIN_TYPE_IMPORT_INFRA)
              suggestion="Move dependency from Domain to Infrastructure or Application layer. Domain must have zero external imports."
              ;;
            INTERFACE_NO_DOMAIN_ACCESS|INTERFACE_TYPE_IMPORT_DOMAIN)
              suggestion="Inject an Application Use Case in the controller instead of importing Domain directly."
              ;;
            INTERFACE_NO_INFRA_ACCESS|INTERFACE_TYPE_IMPORT_INFRA)
              suggestion="Remove direct Infrastructure access from Interface. Route through Application layer."
              ;;
            APPLICATION_NO_INFRA_ACCESS|APPLICATION_TYPE_IMPORT_INFRA)
              suggestion="Define a port/interface in Application and let Infrastructure implement it."
              ;;
            INFRASTRUCTURE_NO_INTERFACE|INFRASTRUCTURE_TYPE_IMPORT_INTERFACE)
              suggestion="Infrastructure must not depend on Interface layer. Reverse the dependency."
              ;;
            *)
              suggestion="Ensure dependencies point inward only: Domain <- Application <- Infrastructure/Interface."
              ;;
          esac

          echo "  - file: $source_file"
          echo "    rule: $rule"
          echo "    severity: $severity"
          echo "    source_layer: $src_layer"
          echo "    imported_layer: $tgt_layer"
          if [ "$is_type_only" = "true" ]; then
            echo "    is_type_only: true"
            echo "    message: $src_layer imports type-only from $tgt_layer (compile-time coupling, no runtime leak)"
          else
            echo "    message: $src_layer imports from $tgt_layer"
          fi
          echo "    suggestion: \"$suggestion\""
          echo "    imported_path: $imported_path"
        fi
      fi

      # Reset for next record
      source_file=""
      imported_path=""
      is_relative=""
      is_type_only=""
    fi
  fi
done < "$IMPORTS_FILE"
