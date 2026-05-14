#!/usr/bin/env bash
set -euo pipefail

# analyze-risks.sh
# Lee un diff YAML de get-diff.sh y detecta riesgos por regex/heuristica.
# Aplica patrones de Seguridad, Datos y Dependencias sobre lineas añadidas.
# Salida: YAML con lista preliminar de riesgos.

DIFF_FILE="${1:-}"

if [[ -z "$DIFF_FILE" || ! -f "$DIFF_FILE" ]]; then
  echo "Error: archivo de diff no encontrado: $DIFF_FILE" >&2
  echo "Uso: $0 <diff.yml>" >&2
  exit 1
fi

echo "risks:"

current_file=""
line_type=""
line_number=""
content=""

check_security() {
  local file="$1"
  local num="$2"
  local text="$3"

  # AWS Access Key ID
  if [[ "$text" =~ AKIA[0-9A-Z]{16} ]]; then
    echo "  - category: \"Seguridad\""
    echo "    severity: \"critical\""
    echo "    rule: \"AWS_KEY_IN_CODE\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"AWS Access Key ID expuesta en codigo fuente\""
    echo "    confidence: \"high\""
  fi

  # MongoDB URI con credenciales
  if [[ "$text" =~ mongodb(\+srv)?://[^:]+:[^@]+@ ]]; then
    echo "  - category: \"Seguridad\""
    echo "    severity: \"critical\""
    echo "    rule: \"MONGO_URI_WITH_PASSWORD\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"URI de MongoDB con credenciales en texto plano\""
    echo "    confidence: \"high\""
  fi

  # Clave privada / secreta generica hardcodeada
  if [[ "$text" =~ (PRIVATE_KEY|private_key|SECRET_KEY|secret_key)[[:space:]]*[:=][[:space:]]*[\"\'][^\"\']{8,}[\"\'] ]]; then
    echo "  - category: \"Seguridad\""
    echo "    severity: \"critical\""
    echo "    rule: \"PRIVATE_KEY_IN_CODE\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"Clave privada o secreta hardcodeada en codigo\""
    echo "    confidence: \"high\""
  fi

  # Archivo .env con valores reales (no placeholders)
  if [[ "$file" == *.env* ]]; then
    if [[ "$text" =~ ^[A-Z_]+[[:space:]]*=[[:space:]]*[\"\']?[A-Za-z0-9_/+=\-]{8,}[\"\']?$ && ! "$text" =~ (PLACEHOLDER|EXAMPLE|TODO|FIXME|YOUR_|change-me|dummy|test|xxx) ]]; then
      echo "  - category: \"Seguridad\""
      echo "    severity: \"high\""
      echo "    rule: \"ENV_WITH_REAL_VALUE\""
      echo "    file: \"$file\""
      echo "    line_number: $num"
      echo "    match: \"${BASH_REMATCH[0]}\""
      echo "    message: \"Archivo .env contiene valor real. Nunca commitear .env con datos reales.\""
      echo "    confidence: \"medium\""
    fi
  fi

  # Token JWT / Bearer expuesto
  if [[ "$text" =~ [Bb]earer[[:space:]]+[A-Za-z0-9_\-\.]{20,} ]]; then
    echo "  - category: \"Seguridad\""
    echo "    severity: \"high\""
    echo "    rule: \"TOKEN_IN_CODE\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"Token JWT o Bearer expuesto en codigo\""
    echo "    confidence: \"medium\""
  fi

  # console.log de datos sensibles
  if [[ "$text" =~ console\.(log|warn|error|debug)[[:space:]]*\(.*(password|secret|token|key|credential|auth) ]]; then
    echo "  - category: \"Seguridad\""
    echo "    severity: \"medium\""
    echo "    rule: \"LOGGED_SECRET\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"Posible secreto logueado en consola\""
    echo "    confidence: \"low\""
  fi
}

check_data() {
  local file="$1"
  local num="$2"
  local text="$3"

  # deleteMany sin WHERE
  if [[ "$text" =~ deleteMany[[:space:]]*\([[:space:]]*\) ]]; then
    echo "  - category: \"Datos\""
    echo "    severity: \"critical\""
    echo "    rule: \"UNCONDITIONAL_DELETE\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"deleteMany() sin clausula WHERE puede borrar toda la tabla\""
    echo "    confidence: \"high\""
  fi

  # SQL destructivo DROP / TRUNCATE TABLE
  if [[ "$text" =~ (DROP[[:space:]]+TABLE|TRUNCATE[[:space:]]+TABLE) ]]; then
    echo "  - category: \"Datos\""
    echo "    severity: \"critical\""
    echo "    rule: \"DESTRUCTIVE_SQL\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"Operacion SQL destructiva (DROP/TRUNCATE) detectada\""
    echo "    confidence: \"high\""
  fi

  # rm -rf con ruta peligrosa
  if [[ "$text" =~ rm[[:space:]]+-rf[[:space:]]+(/|~|\$HOME|\.\/) ]]; then
    echo "  - category: \"Datos\""
    echo "    severity: \"critical\""
    echo "    rule: \"DANGEROUS_RM_RF\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"rm -rf con ruta absoluta o home detectado - peligro de borrado masivo\""
    echo "    confidence: \"high\""
  fi

  # updateMany sin WHERE
  if [[ "$text" =~ updateMany[[:space:]]*\([[:space:]]*\) ]]; then
    echo "  - category: \"Datos\""
    echo "    severity: \"high\""
    echo "    rule: \"UNCONDITIONAL_UPDATE\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"updateMany() sin WHERE puede modificar todos los registros\""
    echo "    confidence: \"high\""
  fi

  # fs.unlink / rimraf con wildcard o ruta no validada
  if [[ "$text" =~ (fs\.unlink|rimraf|unlinkSync)[[:space:]]*\(.*\*/.*\) ]]; then
    echo "  - category: \"Datos\""
    echo "    severity: \"high\""
    echo "    rule: \"UNSAFE_FILE_DELETE\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"Borrado de archivos con wildcard o ruta no validada\""
    echo "    confidence: \"medium\""
  fi
}

check_dependencies() {
  local file="$1"
  local num="$2"
  local text="$3"

  # Solo revisar archivos de manifiesto
  case "$file" in
    package.json|requirements.txt|Cargo.toml|go.mod|pom.xml|build.gradle|Gemfile) ;;
    *) return ;;
  esac

  # Version inestable 0.0.x
  if [[ "$text" =~ \"version\"[[:space:]]*:[[:space:]]*\"(0\.0\.[0-9]+)\" ]]; then
    echo "  - category: \"Dependencias\""
    echo "    severity: \"high\""
    echo "    rule: \"UNSTABLE_DEPENDENCY_VERSION\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"Version 0.0.x de dependencia - tipicamente inestable o no auditada\""
    echo "    confidence: \"medium\""
  fi

  # Dependencia desde fuente no oficial (git/http directo)
  if [[ "$text" =~ (git\+http|git\+ssh|http://) ]]; then
    echo "  - category: \"Dependencias\""
    echo "    severity: \"high\""
    echo "    rule: \"NON_REGISTRY_DEPENDENCY\""
    echo "    file: \"$file\""
    echo "    line_number: $num"
    echo "    match: \"${BASH_REMATCH[0]}\""
    echo "    message: \"Dependencia desde fuente no oficial (git/http directo) - riesgo supply chain\""
    echo "    confidence: \"high\""
  fi
}

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*file:[[:space:]]*\"([^\"]+)\" ]]; then
    current_file="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^[[:space:]]*line_type:[[:space:]]*\"([^\"]+)\" ]]; then
    line_type="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^[[:space:]]*line_number:[[:space:]]*([0-9]+) ]]; then
    line_number="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^[[:space:]]*content:[[:space:]]*\"(.*)\"$ ]]; then
    content="${BASH_REMATCH[1]}"
    # Des-escapar comillas YAML
    content="${content//\\\"/\"}"
    content="${content//\\\\/\\}"

    if [[ "$line_type" == "added" ]]; then
      check_security "$current_file" "$line_number" "$content"
      check_data "$current_file" "$line_number" "$content"
      check_dependencies "$current_file" "$line_number" "$content"
    fi
  fi
done < "$DIFF_FILE"
