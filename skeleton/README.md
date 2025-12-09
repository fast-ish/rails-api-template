# ${{values.name}}

> ${{values.description}}

[![Ruby](https://img.shields.io/badge/Ruby-${{values.rubyVersion}}-red)](https://ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-${{values.railsVersion}}-red)](https://rubyonrails.org/)

## Quick Start

```bash
# Install dependencies
bundle install

{%- if values.database != "none" %}
# Setup database
rails db:create db:migrate db:seed
{%- endif %}

# Start server
rails server
```

Open [http://localhost:3000/health](http://localhost:3000/health) to verify.

## Development

```bash
# Run tests
bundle exec rspec

# Lint
bundle exec rubocop

# Security scan
bundle exec brakeman

{%- if values.jobProcessor == "sidekiq" %}
# Start Sidekiq
bundle exec sidekiq
{%- endif %}
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/health/live` | Liveness probe |
| GET | `/health/ready` | Readiness probe |
| GET | `/api/v1/examples` | List examples |
| POST | `/api/v1/examples` | Create example |
| GET | `/api/v1/examples/:id` | Get example |
| PATCH | `/api/v1/examples/:id` | Update example |
| DELETE | `/api/v1/examples/:id` | Delete example |

## Project Structure

```
app/
├── controllers/api/v1/   # Versioned API controllers
├── models/               # ActiveRecord models
├── serializers/          # JSON serializers
├── services/             # Business logic
└── jobs/                 # Background jobs
config/
├── routes.rb             # API routes
├── database.yml          # Database config
└── initializers/         # Rails initializers
spec/                     # RSpec tests
k8s/                      # Kubernetes manifests
```

## Configuration

Copy `.env.example` to `.env` and configure:

| Variable | Description |
|----------|-------------|
| `RAILS_ENV` | Environment (development/test/production) |
{%- if values.database != "none" %}
| `DATABASE_HOST` | Database host |
| `DATABASE_USER` | Database username |
| `DATABASE_PASSWORD` | Database password |
{%- endif %}
{%- if values.cache == "elasticache-redis" or values.jobProcessor == "sidekiq" %}
| `REDIS_URL` | Redis connection URL |
{%- endif %}
| `OTEL_SERVICE_NAME` | Service name for tracing |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint |

## Deployment

```bash
# Docker
docker build -t ${{values.name}} .
docker run -p 3000:3000 ${{values.name}}

# Kubernetes
kubectl apply -f k8s/
```

## Documentation

- [Getting Started](./docs/GETTING_STARTED.md)
- [Architecture](./docs/architecture.md)
- [Patterns](./docs/PATTERNS.md)
- [Extending](./docs/EXTENDING.md)
- [Troubleshooting](./docs/TROUBLESHOOTING.md)

## Monitoring

- **Grafana Service**: `${{values.name}}`
- **Health Check**: `/health`

## Support

- **Slack**: #platform-help
- **Office Hours**: Thursdays 2-3pm
