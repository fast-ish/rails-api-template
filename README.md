# Rails API Golden Path Template

> The recommended way to build Rails APIs at our organization.

[![Backstage](https://img.shields.io/badge/Backstage-Template-blue)](https://backstage.io)
[![Ruby](https://img.shields.io/badge/Ruby-3.3-red)](https://ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0-red)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/License-Internal-red)]()

## What's Included

| Category | Features |
|----------|----------|
| **Core** | Rails 8.0/7.2, Ruby 3.3/3.2, API-only mode, Puma |
| **Observability** | OpenTelemetry + Grafana, structured logging, health checks |
| **Database** | Aurora PostgreSQL, Aurora MySQL |
| **Cache** | ElastiCache Redis |
| **Jobs** | Sidekiq, Solid Queue |
| **Auth** | Devise + JWT, Doorkeeper (OAuth2) |
| **Serializers** | Alba, Blueprinter, JSON:API |
| **Quality** | RuboCop, Brakeman, RSpec |

## Quick Start

1. Go to [Backstage Software Catalog](https://backstage.yourcompany.com/create)
2. Select "Rails API (Golden Path)"
3. Fill in the form
4. Click "Create"
5. Clone and start building

## What You'll Get

```
your-api/
├── app/
│   ├── controllers/api/v1/  # Versioned API controllers
│   ├── models/              # ActiveRecord models
│   ├── serializers/         # JSON serializers
│   ├── services/            # Business logic
│   └── jobs/                # Background jobs
├── config/                  # Rails configuration
├── spec/                    # RSpec tests
├── k8s/                     # Kubernetes manifests
├── .github/                 # CI/CD workflows
├── docs/                    # Documentation
├── Dockerfile               # Multi-stage build
└── Gemfile                  # Dependencies
```

## Documentation

| Document | Description |
|----------|-------------|
| [Decision Guide](./docs/DECISIONS.md) | How to choose template options |
| [Golden Path Overview](./docs/index.md) | What and why |
| [Getting Started](./skeleton/docs/GETTING_STARTED.md) | First steps |

## Support

- **Slack**: #platform-help
- **Office Hours**: Thursdays 2-3pm

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12 | Initial release |

---

🤘 Platform Team
