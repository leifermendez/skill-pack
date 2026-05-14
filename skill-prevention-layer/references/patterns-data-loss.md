# Patrones de Perdida de Datos

Patrones regex para detectar operaciones destructivas sobre datos en el diff.

## deleteMany sin WHERE

- **Regex:** `deleteMany[[:space:]]*\([[:space:]]*\)`
- **Severidad:** `critical`
- **Regla:** `UNCONDITIONAL_DELETE`
- **Mensaje:** `deleteMany()` sin clausula WHERE puede borrar toda la tabla
- **Nota:** Aplica a Prisma, Mongoose, Sequelize, TypeORM y ORMs similares. `deleteMany()` sin argumento es incondicional.

## SQL destructivo (DROP / TRUNCATE TABLE)

- **Regex:** `(DROP[[:space:]]+TABLE|TRUNCATE[[:space:]]+TABLE)`
- **Severidad:** `critical`
- **Regla:** `DESTRUCTIVE_SQL`
- **Mensaje:** Operacion SQL destructiva (DROP/TRUNCATE) detectada
- **Nota:** `DROP TABLE` elimina la tabla y sus datos. `TRUNCATE` vacia la tabla irreversiblemente. Ambas son criticas en produccion.

## rm -rf peligroso

- **Regex:** `rm[[:space:]]+-rf[[:space:]]+(/|~|\$HOME|\.\/)`
- **Severidad:** `critical`
- **Regla:** `DANGEROUS_RM_RF`
- **Mensaje:** `rm -rf` con ruta absoluta o home detectado - peligro de borrado masivo
- **Nota:** `rm -rf /`, `rm -rf ~`, `rm -rf $HOME`, `rm -rf ./` son destructivos. Rutas relativas simples (ej. `rm -rf ./temp`) son menores pero aun asi riesgosas.

## Borrado de archivos inseguro

- **Regex:** `(fs\.unlink|rimraf|unlinkSync)[[:space:]]*\(.*\*/.*\)`
- **Severidad:** `high`
- **Regla:** `UNSAFE_FILE_DELETE`
- **Mensaje:** Borrado de archivos con wildcard o ruta no validada
- **Nota:** `fs.unlink('/data/*')` o similares con wildcards pueden eliminar mas archivos de los esperados.

## updateMany sin WHERE

- **Regex:** `updateMany[[:space:]]*\([[:space:]]*\)`
- **Severidad:** `high`
- **Regla:** `UNCONDITIONAL_UPDATE`
- **Mensaje:** `updateMany()` sin WHERE puede modificar todos los registros
- **Nota:** Similar a deleteMany. Sin filtro, actualiza toda la tabla.

## DELETE FROM sin WHERE (SQL raw)

- **Regex:** `DELETE[[:space:]]+FROM[[:space:]]+[A-Za-z0-9_]+[[:space:]]*(?!WHERE)`
- **Severidad:** `critical`
- **Regla:** `UNCONDITIONAL_SQL_DELETE`
- **Mensaje:** `DELETE FROM` sin clausula WHERE en SQL raw
- **Nota:** Aplica a queries SQL escritas manualmente. Requiere look-ahead negativo para `WHERE`.

## fs.rmdir / rimraf sin backup

- **Heuristica:** Cambios en scripts de migracion o mantenimiento que usan `fs.rmdir`, `fs.rm` con `recursive: true`, o `rimraf` sin verificacion previa.
- **Severidad:** `medium` a `high` (segun contexto)
- **Regla:** `RECURSIVE_DELETE_NO_BACKUP`
- **Mensaje:** Borrado recursivo sin evidencia de backup previo
- **Nota:** El agente LLM debe validar si existe backup o confirmacion previa en el codigo circundante.
