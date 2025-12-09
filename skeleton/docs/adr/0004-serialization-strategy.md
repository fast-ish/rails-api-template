# ADR-0004: JSON Serialization Strategy

## Status

Accepted

## Date

2025-12

## Context

We need a consistent approach to serializing ActiveRecord objects to JSON for API responses. The solution should be performant, maintainable, and provide a clean separation between models and API representations.

## Decision Drivers

- Performance (serialization speed)
- Developer experience
- Flexibility for complex responses
- Maintainability
- Memory efficiency

## Considered Options

### Option 1: Alba

Modern, high-performance serializer.

**Pros:**
- Fastest Ruby serializer
- Simple DSL
- Flexible output formats
- No dependencies

**Cons:**
- Newer, smaller community
- Less documentation

### Option 2: Blueprinter

Popular, well-documented serializer.

**Pros:**
- Good documentation
- Views for different contexts
- Active development

**Cons:**
- Slower than Alba
- More verbose

### Option 3: ActiveModel Serializers

Rails-integrated serializer.

**Pros:**
- Familiar to Rails developers
- JSON:API support

**Cons:**
- Unmaintained
- Performance issues
- Complex configuration

### Option 4: JSONAPI::Serializer

JSON:API specification compliant.

**Pros:**
- Spec compliant
- Good for public APIs

**Cons:**
- Verbose output
- Not always needed

### Option 5: Jbuilder

Template-based serialization.

**Pros:**
- Ships with Rails
- Flexible

**Cons:**
- Slowest option
- Views mixed with logic

## Decision

{%- if values.serializer == "alba" %}
We will use **Alba** because:

1. Best performance of all Ruby serializers
2. Simple, intuitive DSL
3. No external dependencies
4. Flexible output formats
{%- endif %}

{%- if values.serializer == "blueprinter" %}
We will use **Blueprinter** because:

1. Excellent documentation
2. Views for different contexts
3. Active community
4. Good balance of features and simplicity
{%- endif %}

{%- if values.serializer == "jsonapi-serializer" %}
We will use **JSONAPI::Serializer** because:

1. JSON:API specification compliance needed
2. Standardized format for clients
3. Good for public APIs
{%- endif %}

## Consequences

### Positive

- Consistent JSON structure
- Separation of serialization logic
- Easy to test serializers

### Negative

- Another layer to maintain
- Team needs to learn DSL

### Neutral

- Serializers live in `app/serializers/`

## Implementation

{%- if values.serializer == "alba" %}
```ruby
# app/serializers/user_serializer.rb
class UserSerializer
  include Alba::Resource

  root_key :user

  attributes :id, :email, :name, :created_at

  attribute :full_name do |user|
    "#{user.first_name} #{user.last_name}"
  end

  many :orders, serializer: OrderSerializer
end

# Usage
UserSerializer.new(user).serialize
# => {"user":{"id":1,"email":"...","orders":[...]}}
```
{%- endif %}

{%- if values.serializer == "blueprinter" %}
```ruby
# app/serializers/user_serializer.rb
class UserSerializer < Blueprinter::Base
  identifier :id

  view :default do
    fields :email, :name, :created_at
  end

  view :detailed do
    include_view :default
    association :orders, blueprint: OrderSerializer
  end
end

# Usage
UserSerializer.render(user, view: :detailed)
```
{%- endif %}

{%- if values.serializer == "jsonapi-serializer" %}
```ruby
# app/serializers/user_serializer.rb
class UserSerializer
  include JSONAPI::Serializer

  attributes :email, :name, :created_at

  has_many :orders
end

# Usage
UserSerializer.new(user, include: [:orders]).serializable_hash
```
{%- endif %}

## References

{%- if values.serializer == "alba" %}
- [Alba Documentation](https://github.com/okuramasafumi/alba)
{%- endif %}
{%- if values.serializer == "blueprinter" %}
- [Blueprinter Documentation](https://github.com/procore/blueprinter)
{%- endif %}
{%- if values.serializer == "jsonapi-serializer" %}
- [JSONAPI::Serializer Documentation](https://github.com/jsonapi-serializer/jsonapi-serializer)
- [JSON:API Specification](https://jsonapi.org/)
{%- endif %}
