# Patrones de Seguridad (Secrets)

Patrones regex compilados que `tools/analyze-risks.sh` aplica sobre cada linea añadida (`+`) del diff.

## AWS Access Key ID

- **Regex:** `AKIA[0-9A-Z]{16}`
- **Severidad:** `critical`
- **Regla:** `AWS_KEY_IN_CODE`
- **Mensaje:** AWS Access Key ID expuesta en codigo fuente
- **Nota:** Los Access Key IDs de AWS comienzan con `AKIA` (usuarios IAM) o `ASIA` (credenciales temporales de STS). Ambos deben bloquearse.

## MongoDB URI con credenciales

- **Regex:** `mongodb(\+srv)?://[^:]+:[^@]+@`
- **Severidad:** `critical`
- **Regla:** `MONGO_URI_WITH_PASSWORD`
- **Mensaje:** URI de MongoDB con credenciales en texto plano
- **Nota:** Detecta `mongodb://user:pass@host` o `mongodb+srv://user:pass@host`. El password esta visible antes de `@`.

## Clave privada / Secreto generico hardcodeado

- **Regex:** `(PRIVATE_KEY|private_key|SECRET_KEY|secret_key)[[:space:]]*[:=][[:space:]]*[\"\'][^\"\']{8,}[\"\']`
- **Severidad:** `critical`
- **Regla:** `PRIVATE_KEY_IN_CODE`
- **Mensaje:** Clave privada o secreta hardcodeada en codigo fuente
- **Nota:** Busca asignaciones de variables con nombre claramente sensible y valor no vacio.

## Archivo `.env` con valores reales

- **Condicion:** El archivo modificado coincide con `*.env*` (ej. `.env`, `.env.local`, `.env.production`).
- **Regex heuristica:** `^[A-Z_]+[[:space:]]*=[[:space:]]*[\"\']?[A-Za-z0-9_/+=\-]{8,}[\"\']?$`
- **Exclusiones:** Si la linea contiene `PLACEHOLDER`, `EXAMPLE`, `TODO`, `FIXME`, `YOUR_`, `change-me`, `dummy`, `test`, `xxx` (case-insensitive en el script).
- **Severidad:** `high`
- **Regla:** `ENV_WITH_REAL_VALUE`
- **Mensaje:** Archivo `.env` contiene valor real. Nunca commitear archivos `.env` con datos reales.
- **Nota:** Los `.env` deben estar en `.gitignore`. Si aparecen en el diff con valores reales, es un riesgo grave.

## Token JWT / Bearer expuesto

- **Regex:** `[Bb]earer[[:space:]]+[A-Za-z0-9_\-\.]{20,}`
- **Severidad:** `high`
- **Regla:** `TOKEN_IN_CODE`
- **Mensaje:** Token JWT o Bearer expuesto en codigo fuente
- **Nota:** Tokens largos suelen ser JWTs, API keys o session tokens. Bearer espacios + string > 20 caracteres.

## Console.log de datos sensibles

- **Regex:** `console\.(log|warn|error|debug)[[:space:]]*\(.*(password|secret|token|key|credential|auth)`
- **Severidad:** `medium`
- **Regla:** `LOGGED_SECRET`
- **Mensaje:** Posible secreto logueado en consola
- **Nota:** Heuristica. Puede dar falsos positivos si la variable se llama `tokenCount` o similar. El agente LLM debe validar en el Paso 3.
