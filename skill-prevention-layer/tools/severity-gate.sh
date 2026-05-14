#!/usr/bin/env bash
set -euo pipefail

# severity-gate.sh
# Lee un YAML de riesgos y determina si el cambio debe ser BLOQUEADO.
# Si hay al menos un riesgo 'critical' o 'high', emite gate.block = true.
# No existe modo warn-only ni bypass.

RISKS_FILE="${1:-}"

if [[ -z "$RISKS_FILE" || ! -f "$RISKS_FILE" ]]; then
  echo "Error: archivo de riesgos no encontrado: $RISKS_FILE" >&2
  echo "Uso: $0 <risks.yml>" >&2
  exit 1
fi

BLOCK="false"
MAX_SEVERITY="none"

# Ranking de severidad compatible con bash 3.2+
get_severity_rank() {
  case "$1" in
    critical) echo 3 ;;
    high)     echo 2 ;;
    medium)   echo 1 ;;
    low)      echo 0 ;;
    none)     echo -1 ;;
    *)        echo -1 ;;
  esac
}

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^[[:space:]]*severity:[[:space:]]*\"([^\"]+)\" ]]; then
    sev="${BASH_REMATCH[1]}"
    rank=$(get_severity_rank "$sev")
    max_rank=$(get_severity_rank "$MAX_SEVERITY")

    if [[ $rank -gt $max_rank ]]; then
      MAX_SEVERITY="$sev"
    fi

    if [[ "$sev" == "critical" || "$sev" == "high" ]]; then
      BLOCK="true"
    fi
  fi
done < "$RISKS_FILE"

echo "gate:"
echo "  block: $BLOCK"
if [[ "$BLOCK" == "true" ]]; then
  echo "  reason: \"Riesgos detectados: severidad maxima = $MAX_SEVERITY. Se requiere correccion antes de continuar.\""
else
  echo "  reason: \"Ningun riesgo critico o alto detectado.\""
fi
echo "  max_severity: \"$MAX_SEVERITY\""
