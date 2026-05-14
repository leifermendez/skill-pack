# Matriz de Riesgo

## Categorias

| Categoria | Descripcion | Severidades Permitidas |
|---|---|---|
| 🔴 Seguridad | Tokens, claves, credenciales, secrets hardcodeados, archivos `.env` con valores reales, logs de datos sensibles | `critical`, `high`, `medium` |
| 🟠 Datos | Operaciones de borrado masivo sin filtro, `DROP`/`TRUNCATE`, `rm -rf` peligroso, migraciones destructivas, borrado de archivos sin validacion | `critical`, `high`, `medium` |
| 🟡 Dependencias | Versiones inestables/vulnerables, dependencias de fuentes no oficiales, lockfiles alterados manualmente | `high`, `medium`, `low` |

## Severidades y Acciones

| Severidad | Accion Requerida |
|---|---|
| **critical** | **BLOCK** automatico e irreversible. Requiere correccion obligatoria. No se puede ignorar. |
| **high** | **BLOCK** automatico. Requiere correccion o justificacion documentada (solo con override explicito y aprobacion). |
| **medium** | Reportar. No bloquea el gate, pero requiere revision obligatoria antes de merge. |
| **low** | Reportar informativo. No bloquea. |

## Reglas de Bloqueo NO Negociables

1. Cualquier riesgo `critical` en **Seguridad** bloquea automaticamente.
2. Cualquier riesgo `critical` en **Datos** bloquea automaticamente.
3. Cualquier riesgo `high` en **Dependencias** con CVE conocido o lockfile alterado manualmente bloquea.
4. No existe modo `warn-only` ni bypass automatico.
5. Si hay `critical` o `high`, el gate siempre es `block: true`.
6. En modo `BLOCK`, el reporte final **debe incluir** `actions_required[]` con pasos concretos y ejecutables.
