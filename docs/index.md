# Rails API Golden Path

## What is a Golden Path?

A golden path is a standardized, well-supported way to accomplish a common task. For Rails APIs, this means:

- **Consistent patterns** across all services
- **Built-in observability** with OpenTelemetry + Grafana
- **Security by default** with proper authentication
- **Production-ready** from day one

## Why Use This Template?

### Before (DIY Rails API)
- Days setting up project structure
- Inconsistent patterns across teams
- Missing observability
- Security gaps
- No standardized testing

### After (Golden Path)
- Minutes to scaffold
- Consistent, proven patterns
- Full Grafana integration
- Security best practices
- Test suite included

## Architecture

```
┌─────────┐     ┌────────────┐     ┌────────────┐
│ Request │────▶│ Controller │────▶│  Service   │
└─────────┘     └────────────┘     └────────────┘
                      │                   │
                      ▼                   ▼
                ┌────────────┐     ┌────────────┐
                │ Serializer │     │   Model    │
                └────────────┘     └────────────┘
```

## Supported Options

### Databases
- **Aurora PostgreSQL**: Recommended for most APIs
- **Aurora MySQL**: When MySQL is required

### Background Jobs
- **Sidekiq**: Industry standard, requires Redis
- **Solid Queue**: Rails 8+ native, database-backed

### Authentication
- **Devise + JWT**: Token-based auth
- **Doorkeeper**: OAuth2 provider

### Serializers
- **Alba**: Fastest, recommended
- **Blueprinter**: Popular alternative
- **JSON:API**: Standard format

## Getting Started

1. Create API from Backstage
2. Clone repository
3. Run `bundle install`
4. Configure database
5. Run `rails server`

## Support

- **Slack**: #platform-help
- **Documentation**: This repo
- **Office Hours**: Thursdays 2-3pm
