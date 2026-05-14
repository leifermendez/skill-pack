---
name: skill-prevention-layer
description: >-
  Git diff security and risk auditor. Evaluates ONLY changed code (staged, commit range, or patch file).
  Detects security leaks, data-loss dangers, and dependency risks.
  Outputs structured YAML. Blocks critical/high findings with mandatory fix actions.
compatibility: Universal. Any project using Git.
metadata:
  author: leifermendez
  version: "1.0"
  tags: "security, git, diff, prevention, secrets, data-loss, dependencies, ci-cd"
---

# Prevention Layer — Auditor de Diffs de Git

> **Propósito único:** Auditar únicamente los cambios de un diff de git para detectar riesgos de Seguridad, Pérdida de Datos y Dependencias antes de que avancen a commit, push o merge.
> **No escanea el codebase completo.** Solo evalúa lo que está por comitearse o ya fue comiteado en un rango.
> **Siempre bloquea** ante riesgos `critical` o `high` sin bypass.

---

## Cuándo Usar

- **Pre-commit:** antes de `git commit`, revisar cambios staged (`--staged` por defecto).
- **Pre-push:** antes de `git push`, revisar rango de commits (`--range A..B`).
- **PR Review / CI Gate:** en un pipeline de CI, revisar el diff de la PR vs `main`.
- **Manual:** el usuario solicita "revisa mis cambios antes de commitear".

---

## Matriz de Riesgo

| Categoría | Severidades | Descripción | Umbral de Bloqueo |
|---|---|---|---|
| 🔴 **Seguridad** | `critical`, `high`, `medium` | Tokens hardcodeados, `.env` con valores reales, claves privadas, passwords en código, `console.log` de secrets, certificados, URLs con credenciales | `critical` o `high` sin justificación → **BLOCK** |
| 🟠 **Datos** | `critical`, `high`, `medium` | `deleteMany()` sin `where`, `DROP TABLE`, `TRUNCATE`, migraciones destructivas sin backup, `rm -rf` en scripts, `updateMany` masivo sin filtro | `critical` o `high` sin justificación → **BLOCK** |
| 🟡 **Dependencias** | `high`, `medium`, `low` | Cambio a versión con CVE conocido, nueva librería no auditada, modificación manual de `package-lock.json`/`yarn.lock`/`Cargo.lock`, supply chain sospechoso | `high` con CVE o lockfile alterado → **BLOCK** |

### Reglas de Bloqueo (NO Negociables)

1. Cualquier riesgo `critical` en **Seguridad** bloquea automáticamente.
2. Cualquier riesgo `critical` en **Datos** bloquea automáticamente.
3. Cualquier riesgo `high` en **Dependencias** con CVE conocido o lockfile alterado manualmente bloquea.
4. **No existe modo warn-only ni bypass.** Si hay `critical` o `high`, el gate es `block: true`.
5. En modo `BLOCK`, el reporte YAML **debe incluir** la sección `actions_required[]` con acciones concretas y ejecutables.

---

## Protocolo de 5 Pasos

| Paso | Actor | Script / Acción | Propósito |
|---|---|---|---|
| **1. EXTRAER** | Agente / Script | `bash tools/get-diff.sh [--staged \| --range A..B \| --head N]` | Obtener el diff de git y convertirlo a YAML estructurado (`diff.yml`). |
| **2. DETECTAR** | Script | `bash tools/analyze-risks.sh <diff.yml>` | Aplicar patrones regex y heurísticos definidos en `references/patterns-*.md` sobre cada línea añadida del diff. Genera `risks-preliminary.yml`. |
| **3. REVISAR** | **Agente LLM** | — | Aplica contexto semántico: ¿el `deleteMany()` tiene un filtro implícito en líneas cercanas? ¿el token es un dummy de test o una clave real de producción? Reduce falsos positivos. |
| **4. BLOQUEAR** | Script | `bash tools/severity-gate.sh <risks-reviewed.yml>` | Si existe al menos un riesgo `critical`, o un `high` sin flag de `override: true`, emite `gate: {block: true, reason: "...", max_severity: "critical"}`. |
| **5. REPORTAR** | Agente LLM | — | Genera el YAML final estricto según `references/output-schema.yml`, incluyendo `actions_required[]` con comandos concretos para corregir o revertir cada problema. |

---

## Flujo de Uso (Comandos)

```bash
# Paso 1: Extraer diff staged (por defecto)
bash tools/get-diff.sh > /tmp/diff.yml

# Paso 2: Detectar riesgos por regex
bash tools/analyze-risks.sh /tmp/diff.yml > /tmp/risks.yml

# Paso 3: El agente LLM revisa /tmp/risks.yml y reduce falsos positivos
# (edita /tmp/risks.yml si elimina falsos positivos)

# Paso 4: Gate de severidad
bash tools/severity-gate.sh /tmp/risks.yml > /tmp/gate.yml

# Paso 5: El agente lee /tmp/diff.yml, /tmp/risks.yml, /tmp/gate.yml
# y emite el reporte final YAML segun output-schema.yml
```

---

## Formatos de Entrada de los Scripts

### `get-diff.sh`

**Opciones:**
- `--staged` (default): diff de cambios en staging area.
- `--range A..B`: diff entre dos commits o ramas.
- `--head N`: diff de los últimos N commits (`HEAD~N..HEAD`).
- `--file PATCHFILE`: leer diff desde un archivo patch existente.

**Salida YAML (`diff.yml`):**
```yaml
diff:
  mode: "staged"
  files_changed: 2
  lines_added: 45
  lines_removed: 12
  records:
    - file: "src/config.ts"
      line_type: "added"
      line_number: 15
      content: "AWS_SECRET_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE"
    - file: "src/config.ts"
      line_type: "added"
      line_number: 16
      content: "const x = 1"
    - file: "src/old.ts"
      line_type: "removed"
      line_number: 8
      content: "const old = true"
```

### `analyze-risks.sh`

**Entrada:** YAML de `get-diff.sh`.

**Salida YAML (`risks-preliminary.yml`):**
```yaml
risks:
  - category: "Seguridad"
    severity: "critical"
    rule: "AWS_KEY_IN_CODE"
    file: "src/config.ts"
    line_number: 15
    match: "AWS_SECRET_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE"
    message: "AWS Access Key ID expuesta en codigo fuente"
    confidence: "high"
  - category: "Datos"
    severity: "high"
    rule: "UNCONDITIONAL_DELETE"
    file: "scripts/cleanup.ts"
    line_number: 42
    match: "prisma.user.deleteMany()"
    message: "deleteMany sin WHERE puede borrar toda la tabla"
    confidence: "high"
```

### `severity-gate.sh`

**Entrada:** YAML de riesgos ya revisados (post-agente).

**Salida YAML (`gate.yml`):**
```yaml
gate:
  block: true
  reason: "Riesgos detectados: severidad maxima = critical. Se requiere correccion antes de continuar."
  max_severity: "critical"
```

---

## Salida Final Esperada (Agente LLM)

El agente combina los 3 YAML intermedios y genera el reporte final:

```yaml
scan:
  diff_range: "HEAD~1..HEAD"
  mode: "staged"
  commit_hash: "abc1234"
  files_changed: 3
  lines_added: 45
  lines_removed: 12

risks:
  - category: "Seguridad"
    severity: "critical"
    rule: "AWS_KEY_IN_CODE"
    file: "src/config.ts"
    line_number: 15
    match: "AWS_SECRET_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE"
    message: "AWS Access Key ID expuesta en codigo fuente"
    action: "BLOCK"
    confidence: "high"
    suggestion: "Mover a variable de entorno y rotar el token expuesto inmediatamente"

  - category: "Datos"
    severity: "high"
    rule: "UNCONDITIONAL_DELETE"
    file: "scripts/cleanup.ts"
    line_number: 42
    match: "prisma.user.deleteMany()"
    message: "deleteMany sin WHERE puede borrar toda la tabla"
    action: "BLOCK"
    confidence: "high"
    suggestion: "Agregar clausula where explicita y requerir backup antes de ejecucion"

gate:
  block: true
  reason: "1 critical (Seguridad) + 1 high (Datos)"
  max_severity: "critical"
  pass_conditions: "Requiere correccion de todos los riesgos critical/high"

actions_required:
  - priority: "P0"
    action: "REVERTIR linea 15 de src/config.ts — secreto expuesto"
    command: "git checkout HEAD -- src/config.ts && git add src/config.ts"
  - priority: "P0"
    action: "CORREGIR scripts/cleanup.ts:42 — agregar where a deleteMany"
    suggestion: "Cambiar a prisma.user.deleteMany({ where: { expired: true } })"
```

---

## Checklist del Agente (Cierre)

Antes de emitir el reporte final, el agente debe verificar:

- [ ] El diff evaluado corresponde únicamente a cambios de git (no codebase completo).
- [ ] Se ejecutaron los 3 scripts del protocolo en orden.
- [ ] Todos los riesgos `critical` y `high` tienen `action: BLOCK`.
- [ ] Si `gate.block` es `true`, existe al menos un `actions_required` con prioridad `P0`.
- [ ] Las acciones requeridas son concretas: nombre de archivo, número de línea, comando o sugerencia exacta.
- [ ] Los riesgos `medium` y `low` tienen `action: REVIEW` o `INFO` y no bloquean el gate.
- [ ] El YAML final cumple estrictamente `references/output-schema.yml`.

---

## Referencias

- [`references/risk-matrix.md`](references/risk-matrix.md) — Categorías, severidades y umbrales de bloqueo.
- [`references/patterns-secrets.md`](references/patterns-secrets.md) — Regex para tokens, env, claves, credenciales.
- [`references/patterns-data-loss.md`](references/patterns-data-loss.md) — Regex para operaciones destructivas de datos.
- [`references/patterns-dependencies.md`](references/patterns-dependencies.md) — Regex para riesgo en dependencias.
- [`references/output-schema.yml`](references/output-schema.yml) — Esquema YAML estricto de salida final.

---

> **Capa de prevención: detectar el riesgo antes de que llegue a producción.**
