# CLAUDE.md

Guidance for Claude Code when working with this Rails API.

## Project Overview

Rails ${{values.railsVersion}} API-only application with OpenTelemetry observability (Grafana stack).

## Technology Stack

- **Language**: Ruby ${{values.rubyVersion}}
- **Framework**: Rails ${{values.railsVersion}} (API mode)
- **Web Server**: Puma
{%- if values.database == "aurora-postgresql" %}
- **Database**: PostgreSQL
{%- endif %}
{%- if values.database == "aurora-mysql" %}
- **Database**: MySQL
{%- endif %}
{%- if values.cache == "elasticache-redis" %}
- **Cache**: Redis
{%- endif %}
{%- if values.jobProcessor == "sidekiq" %}
- **Jobs**: Sidekiq
{%- endif %}
{%- if values.jobProcessor == "solid-queue" %}
- **Jobs**: Solid Queue
{%- endif %}
- **Serializer**: ${{values.serializer | title}}
- **Testing**: RSpec
- **Observability**: OpenTelemetry + Grafana

## Common Commands

```bash
# Install dependencies
bundle install

# Start server
rails server

# Run tests
bundle exec rspec

# Lint
bundle exec rubocop

# Security scan
bundle exec brakeman

{%- if values.database != "none" %}
# Database
rails db:create
rails db:migrate
rails db:seed
{%- endif %}

{%- if values.jobProcessor == "sidekiq" %}
# Background jobs
bundle exec sidekiq
{%- endif %}
```

## Architecture

```
app/
├── controllers/api/v1/   # API controllers
├── models/               # ActiveRecord models
├── serializers/          # JSON serializers
├── services/             # Business logic
└── jobs/                 # Background jobs
```

## Patterns

### Controllers
- Inherit from `Api::V1::BaseController`
- Use service objects for business logic
- Return JSON via serializers

### Services
- Inherit from `ApplicationService`
- Call via `.call()` class method
- Return `ServiceResult` (success/failure)

### Serializers
{%- if values.serializer == "alba" %}
- Inherit from `BaseSerializer`
- Use `include Alba::Resource`
{%- endif %}
{%- if values.serializer == "blueprinter" %}
- Inherit from `BaseSerializer`
- Use `Blueprinter::Base`
{%- endif %}

## Conventions

- API versioned under `/api/v1/`
- Use UUIDs for primary keys
- Structured JSON logging
- RSpec for all tests
- RuboCop for linting

## Don't

- Skip tests
- Bypass RuboCop
- Use raw SQL without sanitization
- Expose sensitive data in responses
