# Decision Guide

How to choose the right options for your Rails API.

## Ruby Version

| Choose | When |
|--------|------|
| **3.3** | New projects, want latest features (default) |
| **3.2** | Need LTS stability, existing 3.2 codebase |

## Rails Version

| Choose | When |
|--------|------|
| **8.0** | New projects, want Solid Queue/Cable options |
| **7.2** | Need LTS stability, production-proven |

## Database

| Choose | When |
|--------|------|
| **Aurora PostgreSQL** | Default choice, JSON support, full-text search |
| **Aurora MySQL** | Team familiarity, existing MySQL infrastructure |
| **None** | Stateless service, external data sources only |

## Cache

| Choose | When |
|--------|------|
| **ElastiCache Redis** | Session storage, caching, rate limiting, Sidekiq |
| **None** | Simple APIs without caching needs |

## Job Processor

| Choose | When |
|--------|------|
| **Sidekiq** | High throughput, existing Redis, proven at scale |
| **Solid Queue** | Rails 8+, don't want Redis dependency |
| **None** | No background processing needed |

## Authentication

| Choose | When |
|--------|------|
| **Devise + JWT** | Stateless API auth, mobile clients |
| **Doorkeeper** | OAuth2 provider, third-party integrations |
| **None** | Internal service, external auth gateway |

## Serializer

| Choose | When |
|--------|------|
| **Alba** | Best performance, simple API (default) |
| **Blueprinter** | Team familiarity, good documentation |
| **JSON:API** | Need JSON:API spec compliance |

## Pagination

| Choose | When |
|--------|------|
| **Pagy** | Best performance, simple setup (default) |
| **Kaminari** | Team familiarity, more features |
| **None** | Small datasets, no pagination needed |

## Quick Recommendations

### Standard API
- Ruby: 3.3
- Rails: 8.0
- Database: Aurora PostgreSQL
- Cache: None
- Jobs: None
- Auth: Devise + JWT
- Serializer: Alba
- Pagination: Pagy

### High-Traffic API
- Ruby: 3.3
- Rails: 8.0
- Database: Aurora PostgreSQL
- Cache: ElastiCache Redis
- Jobs: Sidekiq
- Auth: Devise + JWT
- Serializer: Alba
- Pagination: Pagy

### Internal Microservice
- Ruby: 3.3
- Rails: 8.0
- Database: Aurora PostgreSQL
- Cache: None
- Jobs: Solid Queue
- Auth: None
- Serializer: Alba
- Pagination: None
