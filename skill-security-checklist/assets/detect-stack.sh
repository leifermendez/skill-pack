#!/bin/bash
p="${1:-.}"
cd "$p"||exit 1
echo "project_path: $(pwd)"
echo "audit_timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "languages:"
l(){ local n=0 x=$(find . -name "$2"|grep -vE '(node_modules|vendor|\.git|dist|build)'|wc -l);[ -n "$3" ]&&[ -f "$3" ]&&n=$((x+100))||n=$x;[ $n -gt 0 ]&&echo "  - name: $1"$'\n'"    file_count: $n"$'\n'"    config_found: $([ -f "$3" ]&&echo true||echo false)";}
for i in "JavaScript|*.js|package.json" "TypeScript|*.ts|tsconfig.json" "Python|*.py|requirements.txt" "Java|*.java|pom.xml" "Go|*.go|go.mod" "Rust|*.rs|Cargo.toml" "PHP|*.php|composer.json" "Ruby|*.rb|Gemfile" "C#|*.cs|*.csproj" "C/C++|*.c|Makefile" "Swift|*.swift|Package.swift" "Kotlin|*.kt|build.gradle.kts";do IFS='|' read -r a b c<<<"$i";l "$a" "$b" "$c";done
c(){ local f=$1 s=$2;while IFS='|' read -r p n;do [ -n "$p" ]&&grep -q "$p" $f 2>/dev/null&&echo "  - name: $n";done<<<"${s//;/$'\n'}";}
echo "frameworks:"
[ -f package.json ]&&c package.json "react|React;next|Next.js;vue|Vue;express|Express;fastify|Fastify;nestjs|NestJS;prisma|Prisma;mongoose|Mongoose;jest|Jest;cypress|Cypress;playwright|Playwright;tailwindcss|Tailwind CSS;zustand|Zustand;redux|Redux;graphql|GraphQL;apollo|Apollo;kafka|Kafka;aws-sdk|AWS SDK;firebase|Firebase;supabase|Supabase;auth0|Auth0;jsonwebtoken|JWT;bcrypt|Bcrypt;sentry|Sentry;eslint|ESLint;prettier|Prettier"
[ -f requirements.txt ]&&c requirements.txt "django|Django;flask|Flask;fastapi|FastAPI;sqlalchemy|SQLAlchemy;celery|Celery;redis|Redis;psycopg2|PostgreSQL;pymongo|MongoDB;boto3|AWS SDK;requests|Requests;pytest|Pytest;black|Black;flake8|Flake8;mypy|Mypy;pylint|Pylint;bandit|Bandit;cryptography|Cryptography;jwt|JWT;bcrypt|Bcrypt;passlib|Passlib;gunicorn|Gunicorn;uvicorn|Uvicorn;sentry-sdk|Sentry;opentelemetry|OpenTelemetry;ansible|Ansible;terraform|Terraform;serverless|Serverless"
[ -f pom.xml ]&&c pom.xml "spring-boot|Spring Boot;spring-security|Spring Security;hibernate|Hibernate;lombok|Lombok;junit|JUnit;mockito|Mockito;swagger|Swagger;log4j|Log4j;slf4j|SLF4J;jackson|Jackson;gson|Gson;apache-commons|Apache Commons;kafka-clients|Kafka;redis|Redis;elasticsearch|Elasticsearch;prometheus|Prometheus;micrometer|Micrometer"
[ -f build.gradle ]&&c build.gradle* "spring-boot|Spring Boot;kotlin|Kotlin;gradle|Gradle"
[ -f go.mod ]&&c go.mod "gin|Gin;echo|Echo;fiber|Fiber;gorilla/mux|Gorilla Mux;gorm|GORM;sqlx|sqlx;redis|Redis;mongo-driver|MongoDB;aws-sdk-go|AWS SDK;zap|Zap;logrus|Logrus;cobra|Cobra;testify|Testify;grpc|gRPC;kafka|Kafka;prometheus|Prometheus;opentelemetry|OpenTelemetry"
[ -f Cargo.toml ]&&c Cargo.toml "actix-web|Actix Web;rocket|Rocket;axum|Axum;tokio|Tokio;serde|Serde;sqlx|sqlx;diesel|Diesel"
[ -f composer.json ]&&c composer.json "laravel|Laravel;symfony|Symfony;doctrine|Doctrine;phpunit|PHPUnit"
[ -f Gemfile ]&&c Gemfile "rails|Rails;sinatra|Sinatra;rspec|RSpec;sidekiq|Sidekiq"
echo "build_tools:"
for i in "package.json|npm/yarn/pnpm" "requirements.txt|pip" "pom.xml|Maven" "build.gradle|Gradle" "go.mod|Go Modules" "Cargo.toml|Cargo" "composer.json|Composer" "Gemfile|Bundler" "Makefile|Make" "Dockerfile|Docker" "docker-compose.yml|Docker Compose";do [ -f "${i%%|*}" ]&&echo "  - name: ${i##*|}";done
echo "databases:"
[ -f package.json ]&&c package.json "prisma|Prisma (ORM);mongoose|MongoDB;sequelize|Sequelize (ORM);typeorm|TypeORM (ORM);pg|PostgreSQL;mysql|MySQL;redis|Redis"
[ -f requirements.txt ]&&c requirements.txt "psycopg2|PostgreSQL;pymongo|MongoDB;sqlalchemy|SQLAlchemy (ORM)"
[ -f docker-compose.yml ]&&c docker-compose.yml "postgres|PostgreSQL;mysql|MySQL;mongo|MongoDB;redis|Redis"
echo "test_frameworks:"
[ -f package.json ]&&c package.json "jest|Jest;mocha|Mocha;cypress|Cypress;playwright|Playwright;vitest|Vitest"
[ -f requirements.txt ]&&c requirements.txt "pytest|Pytest;unittest|unittest"
[ -f pom.xml ]&&c pom.xml "junit|JUnit;testng|TestNG"
echo "ci_cd:"
for i in ".github/workflows|GitHub Actions" ".gitlab-ci.yml|GitLab CI" "Jenkinsfile|Jenkins" ".circleci/config.yml|CircleCI" "azure-pipelines.yml|Azure Pipelines" "bitbucket-pipelines.yml|Bitbucket Pipelines" ".travis.yml|Travis CI" "cloudbuild.yaml|Google Cloud Build" "buildkite.yml|Buildkite" "drone.yml|Drone CI" "appveyor.yml|AppVeyor" "codecov.yml|Codecov" "sonar-project.properties|SonarQube" ".snyk|Snyk";do [ -d "${i%%|*}" ]||[ -f "${i%%|*}" ]&&echo "  - name: ${i##*|}";done
echo "cloud_providers:"
[ -f package.json ]&&c package.json "aws-sdk|AWS;@aws-sdk|AWS;@azure|Azure;@google-cloud|GCP;firebase|Firebase;supabase|Supabase;vercel|Vercel;netlify|Netlify;heroku|Heroku"
for i in "terraform/main.tf|Terraform" "serverless.yml|Serverless Framework" "pulumi.yaml|Pulumi" "cdk.json|AWS CDK" "samconfig.toml|AWS SAM" "app.yaml|Google App Engine" "netlify.toml|Netlify" "vercel.json|Vercel" "fly.toml|Fly.io" "railway.yml|Railway" "render.yaml|Render" "heroku.yml|Heroku" "docker-compose.yml|Docker Compose";do [ -f "${i%%|*}" ]||[ -d "${i%%|*}" ]&&echo "  - name: ${i##*|}";done
[ -d kubernetes ]&&echo "  - name: Kubernetes"
[ -d .github/workflows ]&&echo "  - name: GitHub Actions"
a=$(find . -type f|grep -vE '(node_modules|vendor|\.git|dist|build|target|\.next)')
printf "summary_stats:\n  total_files: %s\n  source_files: %s\n  config_files: %s\n  test_files: %s\n  documentation_files: %s\n" "$(echo "$a"|wc -l)" "$(echo "$a"|grep -cE '\.(js|ts|jsx|tsx|py|java|go|rs|php|rb|cs|swift|kt|c|cpp|h|hpp)$')" "$(find . -maxdepth 2 -type f|grep -cE '(package|requirements|pom|go\.mod|Cargo|composer|Gemfile|Dockerfile|docker-compose|tsconfig|\.eslintrc|jest|vite|webpack)')" "$(echo "$a"|grep -cE '(test|spec)\.')" "$(echo "$a"|grep -cE '(README|CHANGELOG|CONTRIBUTING|LICENSE|\.md)$')"
[ -f package.json ]&&printf "  dependencies:\n    production: %s\n    development: %s\n    peer: %s\n" "$(grep -c '"dependencies"' package.json 2>/dev/null||echo 0)" "$(grep -c '"devDependencies"' package.json 2>/dev/null||echo 0)" "$(grep -c '"peerDependencies"' package.json 2>/dev/null||echo 0)"
[ -f requirements.txt ]&&printf "  dependencies:\n    total: %s\n" "$(grep -c '^[a-zA-Z]' requirements.txt 2>/dev/null||echo 0)"
[ -f go.mod ]&&printf "  dependencies:\n    total: %s\n" "$(grep -c '^\t' go.mod 2>/dev/null||echo 0)"
[ -f Cargo.toml ]&&printf "  dependencies:\n    total: %s\n" "$(grep -c '^\[dependencies\]' Cargo.toml 2>/dev/null||echo 0)"
