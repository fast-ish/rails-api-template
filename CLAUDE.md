# Rails API Golden Path Template

Backstage software template for generating production-ready Rails APIs with OpenTelemetry observability (Grafana stack).

## Structure

```
/template.yaml          # Backstage scaffolder definition (all parameters here)
/skeleton/              # Generated Rails app template (ERB/Jinja2 templated)
/docs/                  # Template-level documentation
```

## Key Files

- `template.yaml` - Template parameters and steps (scaffolder.backstage.io/v1beta3)
- `skeleton/Gemfile` - Dependencies with conditional inclusions
- `skeleton/config/application.rb` - Rails application setup
- `skeleton/config/initializers/opentelemetry.rb` - OpenTelemetry configuration

## Template Syntax

Uses Jinja2 via Backstage:
- Variables: `${{values.name}}`, `${{values.owner}}`
- Conditionals: `{%- if values.database != "none" %}...{%- endif %}`

## Testing Template Changes

```bash
cd skeleton
bundle install
rails server
bundle exec rspec
bundle exec rubocop
```

## Template Options

| Parameter | Values |
|-----------|--------|
| rubyVersion | 3.3, 3.2 |
| railsVersion | 8.0, 7.2 |
| database | aurora-postgresql, aurora-mysql, none |
| cache | elasticache-redis, none |
| jobProcessor | sidekiq, solid-queue, none |
| actionCable | true, false |
| authentication | devise-jwt, doorkeeper, none |
| serializer | alba, blueprinter, jsonapi-serializer |
| pagination | pagy, kaminari, none |

## Conventions

- API-only mode (no views)
- Versioned API routes (`/api/v1/`)
- Service objects for business logic
- Structured JSON logging with Lograge
- RSpec for testing
- RuboCop for linting

## Version Pinning

Keep these current:
- Rails: 8.0+
- Ruby: 3.3+
- Puma: 6.0+
- opentelemetry-sdk: latest

## Don't

- Include views or assets
- Skip OpenTelemetry instrumentation
- Use unversioned API routes
- Skip type checking where possible
