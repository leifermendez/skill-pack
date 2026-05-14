# Patrones de Riesgo en Dependencias

Patrones aplicados sobre archivos de manifiesto de dependencias.

## Version inestable 0.0.x

- **Archivos objetivo:** `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`
- **Regex:** `"version":[[:space:]]*"(0\.0\.[0-9]+)"`
- **Severidad:** `high`
- **Regla:** `UNSTABLE_DEPENDENCY_VERSION`
- **Mensaje:** Version `0.0.x` de dependencia - tipicamente inestable, no auditada o de desarrollo inicial
- **Nota:** Las versiones `0.0.x` suelen ser releases tempranas sin garantias de estabilidad o seguridad.

## Dependencia desde fuente no oficial

- **Archivos objetivo:** `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, `Gemfile`
- **Regex:** `(git\+http|git\+ssh|http://)`
- **Severidad:** `high`
- **Regla:** `NON_REGISTRY_DEPENDENCY`
- **Mensaje:** Dependencia desde fuente no oficial (git/http directo) - riesgo supply chain
- **Nota:** Instalar desde un repositorio git o URL http directamente expone a supply chain attacks, typosquatting y versiones no verificadas.

## URL de dependencia con protocolo HTTP (no HTTPS)

- **Archivos objetivo:** Cualquier manifiesto de dependencias
- **Regex:** `(http://)[^\s\"]+`
- **Severidad:** `medium`
- **Regla:** `INSECURE_DEPENDENCY_URL`
- **Mensaje:** URL de dependencia usa HTTP sin cifrado
- **Nota:** El download de dependencias por HTTP permite MITM y manipulacion del paquete.

## Lockfiles alterados manualmente

- **Archivos objetivo:** `package-lock.json`, `yarn.lock`, `Cargo.lock`, `poetry.lock`, `Gemfile.lock`, `go.sum`
- **Heuristica:** Cambios en hashes/integrity/sha256 sin un cambio correspondiente en la version del manifiesto principal.
- **Severidad:** `high`
- **Regla:** `LOCKFILE_TAMPERING`
- **Mensaje:** Posible alteracion manual de lockfile - verificar integridad de dependencias
- **Nota:** Los lockfiles deben generarse automaticamente via el package manager (`npm install`, `cargo update`, etc.). Un cambio manual sugiere intento de inyectar una version comprometida.
- **Accion del agente:** En el Paso 3, el agente LLM debe verificar si el diff del lockfile acompaña un cambio legitimo en `package.json`/`requirements.txt` o si es una modificacion aislada sospechosa.

## Nueva dependencia sin fuente conocida

- **Heuristica:** Lineas añadidas en `package.json` bajo `dependencies` o `devDependencies` donde el nombre del paquete es muy similar a uno conocido (typosquatting) o el autor es desconocido / sin perfil npm.
- **Severidad:** `medium` a `high`
- **Regla:** `UNVERIFIED_NEW_DEPENDENCY`
- **Mensaje:** Nueva dependencia no verificada - revisar reputacion y ultima version
- **Nota:** Esta deteccion requiere contexto semantico. El agente LLM debe evaluar si el nombre del paquete es sospechoso o si el download count es anormalmente bajo.
