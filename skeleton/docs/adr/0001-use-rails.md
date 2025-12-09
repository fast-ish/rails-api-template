# ADR-0001: Use Ruby on Rails as Web Framework

## Status

Accepted

## Date

2025-12

## Context

We need to choose a Ruby web framework for building production API services. The framework should provide excellent developer productivity, support modern API patterns, and integrate well with our observability stack.

## Decision Drivers

- Developer productivity (convention over configuration)
- Enterprise adoption and community support
- API-only mode support
- Integration with OpenTelemetry
- Long-term maintainability

## Considered Options

### Option 1: Ruby on Rails (API-only)

Full-featured framework with API-only mode.

**Pros:**
- Convention over configuration
- API-only mode removes unnecessary overhead
- Excellent ActiveRecord ORM
- Mature ecosystem
- Strong security defaults
- Large community and ecosystem

**Cons:**
- Larger footprint than micro-frameworks
- Learning curve for conventions

### Option 2: Sinatra

Lightweight micro-framework.

**Pros:**
- Minimal and lightweight
- Simple to understand
- Flexible structure

**Cons:**
- Requires assembling many components
- No built-in ORM
- Less standardization

### Option 3: Grape

API-focused framework.

**Pros:**
- API-specific DSL
- Built-in parameter validation
- Swagger support

**Cons:**
- Smaller community
- Often used with Rails anyway
- Less standardized patterns

## Decision

We will use **Ruby on Rails (API-only mode)** because:

1. Convention over configuration reduces boilerplate
2. API-only mode removes views/assets overhead
3. ActiveRecord provides excellent database integration
4. Strong security defaults (CSRF, SQL injection prevention)
5. OpenTelemetry has excellent Rails integration
6. Large pool of developers familiar with Rails

## Consequences

### Positive

- Rapid development with generators
- Consistent patterns across services
- Built-in security features
- Excellent testing support with RSpec

### Negative

- Larger memory footprint than Sinatra
- Team needs to follow Rails conventions

### Neutral

- Different structure than Sinatra apps

## Implementation Notes

- Use API-only mode (`rails new --api`)
- Use versioned routes (`/api/v1/`)
- Use service objects for business logic
- Use serializers for JSON responses

## References

- [Rails API-only Applications](https://guides.rubyonrails.org/api_app.html)
- [OpenTelemetry Ruby](https://opentelemetry.io/docs/languages/ruby/)
