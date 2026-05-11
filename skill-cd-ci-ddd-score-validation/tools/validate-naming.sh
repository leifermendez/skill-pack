#!/usr/bin/env bash
set -euo pipefail

# validate-naming.sh
# Validates naming conventions per layer and responsibility type.
# Reads a classify-files YAML.
# Outputs YAML naming issues to stdout.
#
# Usage: bash validate-naming.sh <classified_files.yml>

INPUT_FILE="${1:-}"
if [ -z "$INPUT_FILE" ] || [ ! -f "$INPUT_FILE" ]; then
  echo "Usage: $0 <classified_files.yml>" >&2
  exit 1
fi

echo "naming_issues:"

# Parse classify-files YAML
# We look for blocks with path, layer, type
path=""
layer=""
type=""

while IFS= read -r line; do
  if echo "$line" | grep -qE "^\s+- path:"; then
    path=$(echo "$line" | sed -E 's/^[[:space:]]*- path: //')
    layer=""
    type=""
  elif echo "$line" | grep -qE "^\s+layer:"; then
    layer=$(echo "$line" | sed -E 's/^[[:space:]]*layer: //')
  elif echo "$line" | grep -qE "^\s+type:"; then
    type=$(echo "$line" | sed -E 's/^[[:space:]]*type: //')

    if [ -n "$path" ] && [ -n "$layer" ] && [ -n "$type" ]; then
      base=$(basename "$path")
      base_lower=$(echo "$base" | tr '[:upper:]' '[:lower:]')
      issue=""
      expected=""

      case "$layer/$type" in
        Domain/entity)
          if ! echo "$base_lower" | grep -qE "\.entity\.|\.model\."; then
            issue="true"
            expected="*.entity.{ext} or *.model.{ext}"
          fi
          ;;
        Domain/value-object)
          if ! echo "$base_lower" | grep -qE "\.vo\.|\.value\.|\.value-object\."; then
            issue="true"
            expected="*.vo.{ext} or *.value-object.{ext}"
          fi
          ;;
        Domain/repository-interface)
          if ! echo "$base_lower" | grep -qE "\.repository\.interface\.|\.repo\.interface\.|\.port\."; then
            issue="true"
            expected="*.repository.interface.{ext} or *.port.{ext}"
          fi
          ;;
        Domain/service-domain)
          if ! echo "$base_lower" | grep -qE "\.domain\.service\.|\.domain-service\."; then
            issue="true"
            expected="*.domain.service.{ext}"
          fi
          ;;
        Application/use-case)
          if ! echo "$base_lower" | grep -qE "\.use-case\.|\.usecase\.|\.uc\.|\.interactor\."; then
            issue="true"
            expected="*.use-case.{ext} or *.usecase.{ext}"
          fi
          ;;
        Application/dto)
          if ! echo "$base_lower" | grep -qE "\.dto\.|\.request\.|\.response\.|\.command\.|\.query\."; then
            issue="true"
            expected="*.dto.{ext} or *.request.{ext} or *.response.{ext}"
          fi
          ;;
        Application/port)
          if ! echo "$base_lower" | grep -qE "\.port\.|\.interface\."; then
            issue="true"
            expected="*.port.{ext}"
          fi
          ;;
        Infrastructure/repository-impl)
          if echo "$base_lower" | grep -qE "\.repository\.interface\.|\.repo\.interface\."; then
            # This is actually an interface, not impl
            issue="true"
            expected="repository interfaces should be in Domain layer"
          elif ! echo "$base_lower" | grep -qE "\.repository\.|\.repo\."; then
            issue="true"
            expected="*.repository.{ext}"
          fi
          ;;
        Infrastructure/service-infra)
          if ! echo "$base_lower" | grep -qE "\.service\.|\.adapter\."; then
            issue="true"
            expected="*.service.{ext} or *.adapter.{ext}"
          fi
          ;;
        Infrastructure/adapter)
          if ! echo "$base_lower" | grep -qE "\.adapter\.|\.client\.|\.driver\."; then
            issue="true"
            expected="*.adapter.{ext}"
          fi
          ;;
        Interface/controller)
          if ! echo "$base_lower" | grep -qE "\.controller\.|\.handler\.|\.route\.|\.router\."; then
            issue="true"
            expected="*.controller.{ext} or *.handler.{ext}"
          fi
          ;;
        Interface/middleware)
          if ! echo "$base_lower" | grep -qE "\.middleware\.|\.interceptor\.|\.guard\."; then
            issue="true"
            expected="*.middleware.{ext} or *.interceptor.{ext}"
          fi
          ;;
      esac

      # Also flag style: prefer kebab-case over camelCase or snake_case
      style_issue=""
      if echo "$base" | grep -qE "[A-Z]"; then
        style_issue="camelCase/PascalCase detected"
      elif echo "$base" | grep -qE "_"; then
        style_issue="snake_case detected"
      fi

      if [ "$issue" = "true" ] || [ -n "$style_issue" ]; then
        severity="medium"
        [ -n "$style_issue" ] && severity="low"

        # Determine unique rule code
        rule="FILE_NAMING_MISMATCH"
        if [ -n "$style_issue" ]; then
          rule="FILE_NAMING_MISMATCH"
        fi

        msg=""
        if [ "$issue" = "true" ]; then
          msg="Expected pattern $expected but got $base"
        fi
        if [ -n "$style_issue" ]; then
          msg="$msg Naming style issue: $style_issue. Prefer kebab-case."
        fi

        echo "  - file: $path"
        echo "    layer: $layer"
        echo "    type: $type"
        echo "    rule: $rule"
        echo "    expected_pattern: \"$expected\""
        echo "    actual: $base"
        echo "    severity: $severity"
        echo "    message: \"$msg\""
        echo "    suggestion: \"Rename to kebab-case with layer suffix, e.g., $(echo "$base" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//')\""
      fi

      path=""
      layer=""
      type=""
    fi
  fi
done < "$INPUT_FILE"
