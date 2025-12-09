# ADR-0003: Use Service Objects for Business Logic

## Status

Accepted

## Date

2025-12

## Context

We need a consistent pattern for organizing business logic in our Rails APIs. The pattern should keep controllers thin, improve testability, and provide a clear contract for service operations.

## Decision Drivers

- Testability
- Single responsibility principle
- Reusability across controllers/jobs
- Consistent error handling
- Clear contracts

## Considered Options

### Option 1: Fat Controllers

All logic in controllers.

**Pros:**
- Simple, no extra abstraction

**Cons:**
- Hard to test
- Code duplication
- Mixed responsibilities

### Option 2: Fat Models

Logic in ActiveRecord models.

**Pros:**
- Close to data

**Cons:**
- Models become bloated
- Hard to test in isolation
- Violates SRP

### Option 3: Service Objects

Dedicated classes for business operations.

**Pros:**
- Single responsibility
- Easy to test
- Reusable
- Clear contracts

**Cons:**
- More files
- Learning curve

### Option 4: Interactors/Command Pattern

Using gems like Interactor.

**Pros:**
- Standardized pattern
- Chain operations

**Cons:**
- Additional dependency
- Overkill for simple cases

## Decision

We will use **Service Objects** with a simple Result pattern because:

1. Keeps controllers thin
2. Easy to test in isolation
3. Reusable from controllers, jobs, rake tasks
4. No external dependencies
5. Clear success/failure contract

## Consequences

### Positive

- Thin controllers focused on HTTP concerns
- Services can be composed
- Easy to test with mocks
- Consistent error handling

### Negative

- More files to manage
- Team needs to follow pattern

### Neutral

- Convention to learn

## Implementation

### Base Service

```ruby
# app/services/application_service.rb
class ApplicationService
  def self.call(...)
    new(...).call
  end

  private

  def success(data = nil)
    ServiceResult.new(success: true, data: data)
  end

  def failure(errors)
    ServiceResult.new(success: false, errors: Array(errors))
  end
end

class ServiceResult
  attr_reader :data, :errors

  def initialize(success:, data: nil, errors: [])
    @success = success
    @data = data
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
```

### Usage

```ruby
# app/services/orders/create_service.rb
class Orders::CreateService < ApplicationService
  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    order = @user.orders.build(@params)

    if order.save
      NotifyOrderJob.perform_async(order.id)
      success(order)
    else
      failure(order.errors.full_messages)
    end
  end
end

# Controller
def create
  result = Orders::CreateService.call(user: current_user, params: order_params)

  if result.success?
    render json: OrderSerializer.new(result.data), status: :created
  else
    render json: { errors: result.errors }, status: :unprocessable_entity
  end
end
```

## References

- [Service Objects in Rails](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial)
- [ResultObject Pattern](https://dry-rb.org/gems/dry-monads/)
