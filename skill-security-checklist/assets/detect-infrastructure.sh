#!/bin/bash
# Detect infrastructure: Docker, K8s, CI/CD, cloud providers, databases
# Output: YAML to stdout

PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH" || exit 1

echo "project_path: $(pwd)"
echo "audit_timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Helper: detect file/dir
det() { [ -f "$1" ] || [ -d "$1" ]; }

# Docker
echo "docker:"
if [ -f "Dockerfile" ]; then
  echo "  detected: true"
  echo "  files:"
  echo "    - Dockerfile"
  det ".dockerignore" && echo "    - .dockerignore"
  det "docker-compose.yml" && echo "    - docker-compose.yml"
  det "docker-compose.yaml" && echo "    - docker-compose.yaml"
  det "docker-compose.dev.yml" && echo "    - docker-compose.dev.yml"
  det "docker-compose.prod.yml" && echo "    - docker-compose.prod.yml"
  echo "  base_image: $(grep -m1 '^FROM' Dockerfile 2>/dev/null | sed 's/FROM \(.*\)/\1/' | awk '{print $1}')"
  STAGES=$(grep -c '^FROM' Dockerfile 2>/dev/null || echo 0)
  echo "  stages: $STAGES"
  echo "  multi_stage: $(if [ "$STAGES" -gt 1 ]; then echo "true"; else echo "false"; fi)"
  echo "  user_set: $(if grep -q '^USER' Dockerfile 2>/dev/null; then echo "true"; else echo "false"; fi)"
  echo "  healthcheck: $(if grep -q 'HEALTHCHECK' Dockerfile 2>/dev/null; then echo "true"; else echo "false"; fi)"
  echo "  exposes_ports: $(if grep -q 'EXPOSE' Dockerfile 2>/dev/null; then echo "true"; else echo "false"; fi)"
else
  echo "  detected: false"
fi

# Kubernetes
echo "kubernetes:"
if det "kubernetes" "k8s" "helm" "charts"; then
  echo "  detected: true"
  echo "  manifests:"
  find . -maxdepth 3 -type f \( -name "*.yaml" -o -name "*.yml" \) | grep -E 'k8s|kubernetes|helm|charts' | head -20 | sed 's/^/    - /'
  echo "  helm_charts: $(if det "helm" "charts"; then echo "true"; else echo "false"; fi)"
  echo "  chart_count: $(find . -maxdepth 3 -type f -name "Chart.yaml" | wc -l | tr -d ' ')"
  echo "  kustomize: $(if det "kustomization.yaml" "kustomization.yml"; then echo "true"; else echo "false"; fi)"
else
  echo "  detected: false"
fi

# CI/CD platforms
echo "ci_cd:"
echo "  platforms:"
CICD="false"

cicd_platforms=".github/workflows|GitHub Actions
.gitlab-ci.yml|GitLab CI
Jenkinsfile|Jenkins
.circleci/config.yml|CircleCI
azure-pipelines.yml|Azure Pipelines
bitbucket-pipelines.yml|Bitbucket Pipelines
.travis.yml|Travis CI
cloudbuild.yaml|Google Cloud Build
buildkite.yml|Buildkite
.drone.yml|Drone CI
appveyor.yml|AppVeyor"

while IFS='|' read -r file name; do
  [ -n "$file" ] || continue
  if [ -f "$file" ] || [ -d "$file" ]; then
    echo "    - name: $name"
    [ -f "$file" ] && echo "      file: $file"
    CICD="true"
  fi
done <<< "$cicd_platforms"

[ "$CICD" = "false" ] && echo "    - name: None"

# Cloud providers
echo "cloud_providers:"
CLOUD="false"

cloud_providers="terraform|Terraform|IaC
main.tf|Terraform|IaC
serverless.yml|Serverless Framework|FaaS
pulumi.yaml|Pulumi|IaC
cdk.json|AWS CDK|IaC
samconfig.toml|AWS SAM|FaaS
app.yaml|Google App Engine|PaaS
netlify.toml|Netlify|PaaS
vercel.json|Vercel|PaaS
fly.toml|Fly.io|PaaS
railway.yml|Railway|PaaS
render.yaml|Render|PaaS
heroku.yml|Heroku|PaaS"

while IFS='|' read -r file name type; do
  [ -n "$file" ] || continue
  if [ -f "$file" ] || [ -d "$file" ]; then
    echo "  - name: $name"
    echo "    type: $type"
    [ -f "$file" ] && echo "    file: $file"
    CLOUD="true"
  fi
done <<< "$cloud_providers"

[ "$CLOUD" = "false" ] && echo "  - name: None detected"$'\n'"    type: unknown"

# Database infrastructure
echo "database_infrastructure:"
if [ -f "docker-compose.yml" ]; then
  DBS=$(grep -E 'postgres|mysql|mongo|redis|elasticsearch|mariadb' docker-compose.yml 2>/dev/null | wc -l | tr -d ' ')
  [ "$DBS" -gt 0 ] && echo "  docker_compose_databases:" && grep -E 'postgres|mysql|mongo|redis|elasticsearch|mariadb' docker-compose.yml 2>/dev/null | sed 's/^/    - /'
fi

# Package managers DB detection
db_detect() {
  local file="$1" pkg="$2" name="$3" type="$4"
  [ -f "$file" ] && grep -q "$pkg" "$file" 2>/dev/null && echo "  - name: $name"$'\n'"    type: $type"
}

db_detect "package.json" "prisma" "Prisma" "ORM"
db_detect "package.json" "mongoose" "Mongoose" "ODM"
db_detect "package.json" "sequelize" "Sequelize" "ORM"
db_detect "package.json" "typeorm" "TypeORM" "ORM"
db_detect "package.json" "pg" "PostgreSQL" "driver"
db_detect "package.json" "mysql" "MySQL" "driver"
db_detect "package.json" "redis" "Redis" "cache"
db_detect "requirements.txt" "psycopg2" "PostgreSQL" "driver"
db_detect "requirements.txt" "pymongo" "MongoDB" "driver"
db_detect "requirements.txt" "sqlalchemy" "SQLAlchemy" "ORM"
db_detect "requirements.txt" "redis" "Redis" "cache"

# Security checks
echo "security_checks:"
if [ -f "docker-compose.yml" ] && grep -q 'ports:' docker-compose.yml 2>/dev/null; then
  PORTS=$(grep -A1 'ports:' docker-compose.yml 2>/dev/null | grep -o '[0-9]*:[0-9]*' | wc -l | tr -d ' ')
  echo "  - check: docker_ports_exposed"$'\n'"    count: $PORTS"$'\n'"    risk: medium"$'\n'"    note: Ensure only necessary ports are exposed"
fi

if det ".env" ".env.local" ".env.development" ".env.production"; then
  echo "  - check: env_files_present"$'\n'"    risk: low"$'\n'"    note: .env files present - ensure they are in .gitignore"
  if [ -f ".gitignore" ] && grep -q '.env' .gitignore; then
    echo "    gitignore: true"
  else
    echo "    gitignore: false"$'\n'"    warning: .env files not in .gitignore!"
  fi
fi

# Maturity score
echo "infrastructure_maturity_score:"
SCORE=0
[ -f "Dockerfile" ] && SCORE=$((SCORE + 2))
det "docker-compose.yml" "docker-compose.yaml" && SCORE=$((SCORE + 1))
det "kubernetes" "k8s" && SCORE=$((SCORE + 2))
[ -d ".github/workflows" ] || [ -f ".gitlab-ci.yml" ] || [ -f "Jenkinsfile" ] && SCORE=$((SCORE + 2))
det "terraform" "main.tf" && SCORE=$((SCORE + 2))
[ -f ".env" ] || [ -f ".env.example" ] && SCORE=$((SCORE + 1))
echo "  score: $SCORE"
echo "  max_score: 10"
echo "  percentage: $((SCORE * 10))"

# Recommendations
echo "recommendations:"
[ -f "Dockerfile" ] || echo "  - Add Dockerfile for consistent deployment"
[ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ] || echo "  - Add docker-compose.yml for local development"
[ -d ".github/workflows" ] || [ -f ".gitlab-ci.yml" ] || [ -f "Jenkinsfile" ] || echo "  - Add CI/CD pipeline for automated testing and deployment"
[ -f ".env.example" ] || [ -f ".env.sample" ] || echo "  - Add .env.example for environment variable documentation"
