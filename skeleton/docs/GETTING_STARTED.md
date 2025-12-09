# Getting Started

This guide helps you get the ${{values.name}} Rails API running locally and deployed to production.

## Prerequisites

- Ruby ${{values.rubyVersion}}+
- Bundler 2.5+
{%- if values.database == "aurora-postgresql" %}
- PostgreSQL 16+
{%- endif %}
{%- if values.database == "aurora-mysql" %}
- MySQL 8+
{%- endif %}
{%- if values.cache == "elasticache-redis" or values.jobProcessor == "sidekiq" %}
- Redis 7+
{%- endif %}
- Docker (for containerized deployment)

## Local Development

### 1. Install Dependencies

```bash
bundle install
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your local settings
```

{%- if values.database != "none" %}
### 3. Setup Database

```bash
rails db:create
rails db:migrate
rails db:seed
```
{%- endif %}

### 4. Start the Server

```bash
# Development server
rails server

# Or with specific port
rails server -p 3000
```

{%- if values.jobProcessor == "sidekiq" %}
### 5. Start Sidekiq (Background Jobs)

```bash
bundle exec sidekiq
```
{%- endif %}

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec

# Run specific file
bundle exec rspec spec/requests/health_spec.rb
```

## Code Quality

```bash
# Lint
bundle exec rubocop

# Auto-fix
bundle exec rubocop -A

# Security scan
bundle exec brakeman

# Dependency audit
bundle exec bundle-audit check --update
```

## Docker

### Build Image

```bash
docker build -t ${{values.name}}:latest .
```

### Run Container

```bash
docker run -p 3000:3000 --env-file .env ${{values.name}}:latest
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /health | Health check |
| GET | /api/v1/health | API health with version |

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `RAILS_ENV` | Environment | development |
{%- if values.database != "none" %}
| `DATABASE_HOST` | Database host | localhost |
| `DATABASE_USER` | Database user | postgres |
| `DATABASE_PASSWORD` | Database password | - |
{%- endif %}
{%- if values.cache == "elasticache-redis" or values.jobProcessor == "sidekiq" %}
| `REDIS_URL` | Redis connection URL | redis://localhost:6379/0 |
{%- endif %}
| `OTEL_SERVICE_NAME` | Service name for tracing | ${{values.name}} |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | http://localhost:4318 |

## Deployment

### Kubernetes

```bash
# Create secrets
kubectl create secret generic ${{values.name}}-secrets \
  --from-env-file=.env

# Deploy
kubectl apply -k k8s/base/
```

## Monitoring

- **Grafana Service**: `${{values.name}}`
- **Health Check**: `/health`
- **Traces**: Grafana Tempo via OpenTelemetry

## Troubleshooting

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues.
