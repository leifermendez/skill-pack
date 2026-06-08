#!/bin/bash
# Detect architecture patterns: DDD, MVC, Hexagonal, Clean, Monolith, Microservices, etc.
# Output: YAML to stdout

PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH" || exit 1

echo "project_path: $(pwd)"
echo "audit_timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Detect source root
SOURCE_ROOT=""
for d in src app lib source codebase packages; do
  [ -d "$d" ] && SOURCE_ROOT="$d" && break
done
[ -z "$SOURCE_ROOT" ] && SOURCE_ROOT="."
echo "source_root: $SOURCE_ROOT"

# Helper: check if any directory exists
has_dir() {
  for d in "$@"; do
    [ -d "$d" ] && return 0
  done
  return 1
}

# Helper: detect pattern by directories
pat_dir() {
  local name="$1" conf="$2"; shift 2
  has_dir "$@" && { echo "  $name:"; echo "    detected: true"; echo "    confidence: $conf"; } || { echo "  $name:"; echo "    detected: false"; echo "    confidence: low"; }
}

# Helper: detect pattern by grep
pat_grep() {
  local name="$1" conf="$2" pattern="$3"
  if grep -ri "$pattern" "$SOURCE_ROOT" 2>/dev/null | head -1 > /dev/null; then
    echo "  $name:"; echo "    detected: true"; echo "    confidence: $conf"
  else
    echo "  $name:"; echo "    detected: false"; echo "    confidence: low"
  fi
}

# Detect layers
echo "layers_detected:"
if [ "$SOURCE_ROOT" != "." ]; then
  has_dir "$SOURCE_ROOT/domain" "$SOURCE_ROOT/domains" && echo "  - name: Domain"$'\n'"    path: $SOURCE_ROOT/domain"$'\n'"    role: core"$'\n'"    confidence: high"
  has_dir "$SOURCE_ROOT/application" "$SOURCE_ROOT/app" "$SOURCE_ROOT/use-cases" "$SOURCE_ROOT/usecases" "$SOURCE_ROOT/use_cases" && echo "  - name: Application"$'\n'"    path: $SOURCE_ROOT/application"$'\n'"    role: orchestration"$'\n'"    confidence: high"
  has_dir "$SOURCE_ROOT/infrastructure" "$SOURCE_ROOT/infra" "$SOURCE_ROOT/external" "$SOURCE_ROOT/adapters" && echo "  - name: Infrastructure"$'\n'"    path: $SOURCE_ROOT/infrastructure"$'\n'"    role: implementation"$'\n'"    confidence: high"
  has_dir "$SOURCE_ROOT/interface" "$SOURCE_ROOT/presentation" "$SOURCE_ROOT/ui" "$SOURCE_ROOT/views" "$SOURCE_ROOT/controllers" "$SOURCE_ROOT/routes" && echo "  - name: Interface"$'\n'"    path: $SOURCE_ROOT/interface"$'\n'"    role: delivery"$'\n'"    confidence: high"
fi

# Detect patterns
echo "architecture_analysis:"
pat_dir "mvc" "high" "$SOURCE_ROOT/models" "$SOURCE_ROOT/model" "$SOURCE_ROOT/entities" "$SOURCE_ROOT/entity"
pat_dir "microservices" "medium" "services" "microservices" "svc" "service"
pat_dir "serverless" "high" "$SOURCE_ROOT/functions" "$SOURCE_ROOT/lambdas" "$SOURCE_ROOT/handlers"
pat_dir "event_driven" "medium" "events" "event" "messaging" "messages" "queues" "topics"
pat_dir "monolith" "medium" "$SOURCE_ROOT/monolith" "$SOURCE_ROOT/app"
pat_dir "hexagonal" "high" "$SOURCE_ROOT/ports" "$SOURCE_ROOT/adapters" "$SOURCE_ROOT/driven" "$SOURCE_ROOT/driving"
pat_dir "layered" "medium" "$SOURCE_ROOT/business" "$SOURCE_ROOT/data" "$SOURCE_ROOT/service" "$SOURCE_ROOT/services"
pat_dir "repository_pattern" "high" "$SOURCE_ROOT/repositories" "$SOURCE_ROOT/repository" "$SOURCE_ROOT/repos"
pat_dir "cqrs" "high" "$SOURCE_ROOT/commands" "$SOURCE_ROOT/queries" "$SOURCE_ROOT/command" "$SOURCE_ROOT/query"
pat_dir "saga" "high" "$SOURCE_ROOT/sagas" "$SOURCE_ROOT/saga" "$SOURCE_ROOT/orchestrators" "$SOURCE_ROOT/orchestrator"
pat_dir "api_gateway" "high" "$SOURCE_ROOT/gateway" "$SOURCE_ROOT/gateways" "$SOURCE_ROOT/proxy" "$SOURCE_ROOT/proxies"
pat_dir "service_mesh" "high" "istio" "linkerd"
pat_dir "bff" "high" "$SOURCE_ROOT/bff" "$SOURCE_ROOT/backend-for-frontend" "$SOURCE_ROOT/client-api"
pat_dir "plugin" "high" "$SOURCE_ROOT/plugins" "$SOURCE_ROOT/extensions" "$SOURCE_ROOT/modules" "$SOURCE_ROOT/addons"
pat_grep "circuit_breaker" "high" "circuit breaker\|CircuitBreaker\|circuit_breaker"
pat_grep "strategy" "medium" "strategy\|Strategy\|strategies"
pat_grep "factory" "medium" "factory\|Factory\|createInstance\|createObject"
pat_grep "observer" "medium" "observer\|Observer\|subscribe\|publish\|emit\|eventEmitter"
pat_grep "dependency_injection" "high" "inject\|Inject\|Injectable\|provider\|Provider\|DI\|dependency injection"
pat_grep "sidecar" "medium" "sidecar\|Sidecar"
pat_grep "graphql_federation" "high" "@key\|@extends\|@external\|@provides\|@requires\|federation\|Federation"
pat_grep "multi_tenant" "medium" "tenant\|Tenant\|tenancy\|Tenancy\|multi-tenant\|multitenant"

# Calculate primary pattern
PRIMARY="Unknown / Ad-hoc"
PRIMARY_CONFIDENCE="low"
SECONDARY=""

if has_dir "$SOURCE_ROOT/domain" "$SOURCE_ROOT/domains"; then
  PRIMARY="Domain-Driven Design (DDD)"; PRIMARY_CONFIDENCE="high"
  has_dir "$SOURCE_ROOT/models" "$SOURCE_ROOT/model" && SECONDARY="Model-View-Controller (MVC)"
elif has_dir "$SOURCE_ROOT/models" "$SOURCE_ROOT/model" "$SOURCE_ROOT/views" "$SOURCE_ROOT/view" "$SOURCE_ROOT/controllers" "$SOURCE_ROOT/controller"; then
  PRIMARY="Model-View-Controller (MVC)"; PRIMARY_CONFIDENCE="high"
  has_dir "$SOURCE_ROOT/ports" "$SOURCE_ROOT/adapters" && SECONDARY="Hexagonal Architecture"
elif has_dir "services" "microservices" "svc" "service"; then
  PRIMARY="Microservices"; PRIMARY_CONFIDENCE="high"
elif has_dir "$SOURCE_ROOT/functions" "$SOURCE_ROOT/lambdas" "$SOURCE_ROOT/handlers"; then
  PRIMARY="Serverless"; PRIMARY_CONFIDENCE="high"
elif has_dir "$SOURCE_ROOT/ports" "$SOURCE_ROOT/adapters"; then
  PRIMARY="Hexagonal Architecture"; PRIMARY_CONFIDENCE="high"
fi

echo "primary_pattern:"
echo "  name: $PRIMARY"
echo "  confidence: $PRIMARY_CONFIDENCE"
echo "secondary_pattern:"
echo "  name: ${SECONDARY:-None}"
echo "  confidence: low"

# Architecture score
echo "architecture_score:"
SCORE=0
has_dir "$SOURCE_ROOT/domain" "$SOURCE_ROOT/domains" && SCORE=$((SCORE + 2))
has_dir "$SOURCE_ROOT/models" "$SOURCE_ROOT/model" "$SOURCE_ROOT/views" "$SOURCE_ROOT/view" && SCORE=$((SCORE + 2))
has_dir "$SOURCE_ROOT/ports" "$SOURCE_ROOT/adapters" && SCORE=$((SCORE + 2))
has_dir "$SOURCE_ROOT/business" "$SOURCE_ROOT/data" "$SOURCE_ROOT/service" "$SOURCE_ROOT/services" && SCORE=$((SCORE + 1))
has_dir "$SOURCE_ROOT/repositories" "$SOURCE_ROOT/repository" "$SOURCE_ROOT/repos" && SCORE=$((SCORE + 1))
has_dir "services" "microservices" "svc" "service" && SCORE=$((SCORE + 1))
[ -f "package.json" ] && grep -q 'workspaces' package.json 2>/dev/null && SCORE=$((SCORE + 1))
echo "  score: $SCORE"
echo "  max_score: 10"
echo "  percentage: $((SCORE * 10))"

# Layer violations
echo "layer_violations:"
if [ "$SOURCE_ROOT" != "." ]; then
  [ -d "$SOURCE_ROOT/domain" ] && [ -d "$SOURCE_ROOT/infrastructure" ] && grep -r "from.*infrastructure\|import.*infrastructure\|require.*infrastructure" "$SOURCE_ROOT/domain" 2>/dev/null | head -1 > /dev/null && echo "  - rule: DOMAIN_NO_INFRA"$'\n'"    severity: critical"$'\n'"    message: Domain layer imports from Infrastructure"$'\n'"    suggestion: Move infrastructure dependencies to Application layer"
  [ -d "$SOURCE_ROOT/interface" ] && [ -d "$SOURCE_ROOT/domain" ] && grep -r "from.*domain\|import.*domain\|require.*domain" "$SOURCE_ROOT/interface" 2>/dev/null | grep -v "from.*application" | head -1 > /dev/null && echo "  - rule: INTERFACE_DIRECT_DOMAIN"$'\n'"    severity: warning"$'\n'"    message: Interface layer imports directly from Domain"$'\n'"    suggestion: Interface should only import from Application layer"
fi

# Technology hints
echo "technology_hints:"
[ -f "package.json" ] && grep -q 'next' package.json 2>/dev/null && echo "  - hint: Next.js detected - likely App Router or Pages Router"
[ -f "package.json" ] && grep -q 'nestjs' package.json 2>/dev/null && echo "  - hint: NestJS detected - likely Modular Monolith"
[ -f "package.json" ] && grep -q 'express' package.json 2>/dev/null && echo "  - hint: Express detected - likely MVC or Layered"
[ -f "pom.xml" ] && grep -q 'spring-boot' pom.xml 2>/dev/null && echo "  - hint: Spring Boot detected - likely Layered"
