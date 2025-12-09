# Rails API Patterns

Production-ready patterns included in this template.

## Structured Logging

All logging uses structured JSON format via Lograge for Grafana Loki ingestion:

```ruby
# Automatic structured logging
Rails.logger.info("Processing order", order_id: "123", user_id: "456")

# In controllers - request context is automatic
def create
  Rails.logger.info("creating_resource", params: resource_params.to_h)
end
```

Logs automatically include:
- `correlation_id` - Request tracing (X-Request-ID)
- `trace_id` - OpenTelemetry trace correlation
- `span_id` - OpenTelemetry span correlation
- `environment` - dev/staging/prod

## Service Objects

Use service objects for business logic:

```ruby
# app/services/orders/create_service.rb
class Orders::CreateService < ApplicationService
  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    order = Order.new(@params)
    order.user = @user

    if order.save
      success(order)
    else
      failure(order.errors.full_messages)
    end
  end
end

# Usage in controller
def create
  result = Orders::CreateService.call(user: current_user, params: order_params)

  if result.success?
    render json: OrderSerializer.new(result.data), status: :created
  else
    render json: { errors: result.errors }, status: :unprocessable_entity
  end
end
```

## Exception Handling

Consistent error responses via ApplicationController:

```ruby
# Automatic error handling
class Api::V1::OrdersController < ApplicationController
  def show
    order = Order.find(params[:id])  # Raises RecordNotFound -> 404
    render json: OrderSerializer.new(order)
  end
end

# Custom errors
class OrderService
  def process(order)
    raise UnprocessableEntityError, "Order already processed" if order.processed?
    # ...
  end
end
```

All exceptions return consistent JSON:

```json
{
  "error": "Record not found",
  "correlation_id": "abc-123"
}
```

{%- if values.serializer == "alba" %}

## Serialization (Alba)

Fast JSON serialization with Alba:

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer
  include Alba::Resource

  root_key :order

  attributes :id, :status, :total, :created_at

  attribute :formatted_total do |order|
    "$%.2f" % order.total
  end

  one :user, serializer: UserSerializer
  many :line_items, serializer: LineItemSerializer
end

# Usage
OrderSerializer.new(order).serialize
# => {"order":{"id":1,"status":"pending",...}}
```
{%- endif %}

{%- if values.serializer == "blueprinter" %}

## Serialization (Blueprinter)

JSON serialization with Blueprinter:

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer < Blueprinter::Base
  identifier :id

  fields :status, :total, :created_at

  field :formatted_total do |order|
    "$%.2f" % order.total
  end

  association :user, blueprint: UserSerializer
  association :line_items, blueprint: LineItemSerializer
end

# Usage
OrderSerializer.render(order)
```
{%- endif %}

{%- if values.pagination == "pagy" %}

## Pagination (Pagy)

High-performance pagination with Pagy:

```ruby
class Api::V1::OrdersController < ApplicationController
  def index
    @pagy, @orders = pagy(Order.all, items: params[:per_page] || 20)

    render json: {
      data: OrderSerializer.new(@orders),
      meta: pagy_metadata(@pagy)
    }
  end
end
```

Response includes pagination metadata:

```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "items": 20,
    "count": 100,
    "pages": 5
  }
}
```
{%- endif %}

{%- if values.pagination == "kaminari" %}

## Pagination (Kaminari)

Pagination with Kaminari:

```ruby
class Api::V1::OrdersController < ApplicationController
  def index
    @orders = Order.page(params[:page]).per(params[:per_page] || 20)

    render json: {
      data: OrderSerializer.new(@orders),
      meta: {
        current_page: @orders.current_page,
        total_pages: @orders.total_pages,
        total_count: @orders.total_count
      }
    }
  end
end
```
{%- endif %}

## Health Checks

Three-probe pattern for Kubernetes:

```ruby
# Liveness - is the process running?
GET /health/live
# => { "status": "ok" }

# Readiness - can we serve traffic?
GET /health/ready
# Checks database, Redis, etc.
# => { "status": "ok", "database": "ok", "redis": "ok" }
```

## Correlation IDs

Every request gets a unique correlation ID for distributed tracing:

```ruby
# Automatic via middleware
# Access in any controller/service
correlation_id = request.request_id

# Propagate to downstream services
response = Faraday.get(url) do |req|
  req.headers["X-Request-ID"] = request.request_id
end
```

{%- if values.database != "none" %}

## Database Patterns

### Query Scopes

```ruby
class Order < ApplicationRecord
  scope :pending, -> { where(status: "pending") }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :created_after, ->(date) { where("created_at > ?", date) }
end

# Chainable
Order.pending.for_user(123).recent.limit(10)
```

### Transactions

```ruby
class OrderService
  def process(order)
    ActiveRecord::Base.transaction do
      order.update!(status: "processing")
      payment = PaymentService.charge(order)
      order.update!(status: "completed", payment_id: payment.id)
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("order_processing_failed", error: e.message)
    raise
  end
end
```
{%- endif %}

{%- if values.cache == "elasticache-redis" %}

## Caching

### Fragment Caching

```ruby
class OrderSerializer
  include Alba::Resource

  # Cache serialized output
  def serialize
    Rails.cache.fetch("order:#{object.id}:v1", expires_in: 1.hour) do
      super
    end
  end
end
```

### Low-Level Caching

```ruby
class OrderService
  def expensive_calculation(order_id)
    Rails.cache.fetch("order:#{order_id}:calculation", expires_in: 15.minutes) do
      # Expensive operation
      Order.find(order_id).calculate_totals
    end
  end

  def invalidate(order_id)
    Rails.cache.delete("order:#{order_id}:calculation")
  end
end
```
{%- endif %}

{%- if values.jobProcessor == "sidekiq" %}

## Background Jobs (Sidekiq)

```ruby
# app/jobs/order_notification_job.rb
class OrderNotificationJob
  include Sidekiq::Job

  sidekiq_options queue: :default, retry: 3

  def perform(order_id)
    order = Order.find(order_id)
    NotificationService.send_order_confirmation(order)
  end
end

# Enqueue
OrderNotificationJob.perform_async(order.id)

# Delayed
OrderNotificationJob.perform_in(5.minutes, order.id)

# Scheduled
OrderNotificationJob.perform_at(order.ship_date, order.id)
```
{%- endif %}

{%- if values.jobProcessor == "solid-queue" %}

## Background Jobs (Solid Queue)

```ruby
# app/jobs/order_notification_job.rb
class OrderNotificationJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(order_id)
    order = Order.find(order_id)
    NotificationService.send_order_confirmation(order)
  end
end

# Enqueue
OrderNotificationJob.perform_later(order.id)

# Delayed
OrderNotificationJob.set(wait: 5.minutes).perform_later(order.id)

# Scheduled
OrderNotificationJob.set(wait_until: order.ship_date).perform_later(order.id)
```
{%- endif %}

{%- if values.authentication == "devise-jwt" %}

## Authentication (Devise + JWT)

```ruby
# Protect endpoints
class Api::V1::OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders
    render json: OrderSerializer.new(@orders)
  end
end

# Login returns JWT
POST /api/v1/auth/sign_in
{ "email": "user@example.com", "password": "secret" }
# => { "token": "eyJ...", "user": {...} }

# Use token in requests
Authorization: Bearer eyJ...
```
{%- endif %}

{%- if values.authentication == "doorkeeper" %}

## Authentication (Doorkeeper OAuth2)

```ruby
# Protect endpoints
class Api::V1::OrdersController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    @orders = current_resource_owner.orders
    render json: OrderSerializer.new(@orders)
  end
end

# OAuth2 token request
POST /oauth/token
{
  "grant_type": "client_credentials",
  "client_id": "...",
  "client_secret": "..."
}
# => { "access_token": "...", "token_type": "Bearer" }
```
{%- endif %}

## Security Headers

Automatically added via Rack middleware:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 0`
- `Strict-Transport-Security` (production)
- `Content-Security-Policy`

## Input Validation

Use Strong Parameters and model validations:

```ruby
# Controller
def order_params
  params.require(:order).permit(:product_id, :quantity, :shipping_address)
end

# Model
class Order < ApplicationRecord
  validates :product_id, presence: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :shipping_address, presence: true, length: { maximum: 500 }
end
```
