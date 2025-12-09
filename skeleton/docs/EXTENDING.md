# Extending Your Service

This guide shows how to customize and extend the generated service for your specific needs.

## Table of Contents

- [Adding a New Domain](#adding-a-new-domain)
- [Database Integration](#database-integration)
- [Caching Strategies](#caching-strategies)
- [Background Jobs](#background-jobs)
- [External API Integration](#external-api-integration)
- [Custom Middleware](#custom-middleware)
- [Testing Patterns](#testing-patterns)

---

## Adding a New Domain

### 1. Generate Model

{%- if values.database != "none" %}
```bash
rails generate model Product name:string description:text price:decimal status:integer
rails db:migrate
```
{%- endif %}

### 2. Create Serializer

{%- if values.serializer == "alba" %}
```ruby
# app/serializers/product_serializer.rb
class ProductSerializer
  include Alba::Resource

  root_key :product

  attributes :id, :name, :description, :price, :status, :created_at

  attribute :formatted_price do |product|
    "$%.2f" % product.price
  end

  attribute :status_label do |product|
    product.status.to_s.humanize
  end
end
```
{%- endif %}

{%- if values.serializer == "blueprinter" %}
```ruby
# app/serializers/product_serializer.rb
class ProductSerializer < Blueprinter::Base
  identifier :id

  fields :name, :description, :price, :status, :created_at

  field :formatted_price do |product|
    "$%.2f" % product.price
  end
end
```
{%- endif %}

{%- if values.serializer == "jsonapi-serializer" %}
```ruby
# app/serializers/product_serializer.rb
class ProductSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :price, :status, :created_at

  attribute :formatted_price do |product|
    "$%.2f" % product.price
  end
end
```
{%- endif %}

### 3. Create Service

```ruby
# app/services/products/create_service.rb
class Products::CreateService < ApplicationService
  def initialize(params:, current_user: nil)
    @params = params
    @current_user = current_user
  end

  def call
    product = Product.new(@params)
    product.created_by = @current_user if @current_user

    if product.save
      success(product)
    else
      failure(product.errors.full_messages)
    end
  end
end

# app/services/products/list_service.rb
class Products::ListService < ApplicationService
  def initialize(params: {})
    @params = params
  end

  def call
    products = Product.all
    products = products.where(status: @params[:status]) if @params[:status].present?
    products = products.order(created_at: :desc)

    success(products)
  end
end
```

### 4. Create Controller

```ruby
# app/controllers/api/v1/products_controller.rb
class Api::V1::ProductsController < Api::V1::BaseController
  def index
    result = Products::ListService.call(params: filter_params)

    if result.success?
      {%- if values.pagination == "pagy" %}
      @pagy, products = pagy(result.data)
      render json: {
        data: ProductSerializer.new(products).serialize,
        meta: pagy_metadata(@pagy)
      }
      {%- else %}
      render json: ProductSerializer.new(result.data)
      {%- endif %}
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def show
    product = Product.find(params[:id])
    render json: ProductSerializer.new(product)
  end

  def create
    result = Products::CreateService.call(
      params: product_params,
      current_user: current_user
    )

    if result.success?
      render json: ProductSerializer.new(result.data), status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def update
    product = Product.find(params[:id])

    if product.update(product_params)
      render json: ProductSerializer.new(product)
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    product = Product.find(params[:id])
    product.destroy
    head :no_content
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :status)
  end

  def filter_params
    params.permit(:status, :page, :per_page)
  end
end
```

### 5. Add Routes

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :products
  end
end
```

### 6. Write Tests

```ruby
# spec/requests/api/v1/products_spec.rb
RSpec.describe "Api::V1::Products" do
  describe "GET /api/v1/products" do
    let!(:products) { create_list(:product, 3) }

    it "returns all products" do
      get "/api/v1/products"

      expect(response).to have_http_status(:ok)
      expect(json_response["data"].size).to eq(3)
    end
  end

  describe "POST /api/v1/products" do
    let(:valid_params) do
      { product: { name: "Test", price: 9.99 } }
    end

    it "creates a product" do
      expect {
        post "/api/v1/products", params: valid_params
      }.to change(Product, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end
end

# spec/factories/products.rb
FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price }
    status { :active }
  end
end
```

---

{%- if values.database != "none" %}

## Database Integration

### Query Scopes

```ruby
# app/models/product.rb
class Product < ApplicationRecord
  enum :status, { draft: 0, active: 1, discontinued: 2 }

  scope :available, -> { where(status: :active) }
  scope :priced_between, ->(min, max) { where(price: min..max) }
  scope :search, ->(query) { where("name ILIKE ?", "%#{query}%") }
  scope :recent, -> { order(created_at: :desc) }
end
```

### Complex Queries

```ruby
class Products::SearchService < ApplicationService
  def initialize(query:, filters: {})
    @query = query
    @filters = filters
  end

  def call
    products = Product.available

    products = products.search(@query) if @query.present?
    products = products.priced_between(@filters[:min_price], @filters[:max_price]) if @filters[:min_price]
    products = products.where(category_id: @filters[:category_id]) if @filters[:category_id]

    success(products.recent)
  end
end
```

### Transactions

```ruby
class Orders::CreateService < ApplicationService
  def call
    ActiveRecord::Base.transaction do
      order = Order.create!(order_params)

      items.each do |item|
        order.line_items.create!(item)
        Product.find(item[:product_id]).decrement!(:stock, item[:quantity])
      end

      success(order)
    end
  rescue ActiveRecord::RecordInvalid => e
    failure(e.record.errors.full_messages)
  end
end
```

### Migrations

```bash
# Add column
rails generate migration AddCategoryToProducts category:references

# Add index
rails generate migration AddIndexToProductsName

# In migration
add_index :products, :name
add_index :products, [:status, :created_at]
```
{%- endif %}

---

{%- if values.cache == "elasticache-redis" %}

## Caching Strategies

### Fragment Caching

```ruby
class ProductSerializer
  include Alba::Resource

  def serialize
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      super
    end
  end

  private

  def cache_key
    "product:#{object.id}:#{object.updated_at.to_i}"
  end
end
```

### Service-Level Caching

```ruby
class Products::GetService < ApplicationService
  def initialize(id:)
    @id = id
  end

  def call
    product = Rails.cache.fetch("products:#{@id}", expires_in: 15.minutes) do
      Product.find(@id)
    end

    success(product)
  rescue ActiveRecord::RecordNotFound
    failure(["Product not found"])
  end
end
```

### Cache Invalidation

```ruby
class Product < ApplicationRecord
  after_commit :invalidate_cache

  private

  def invalidate_cache
    Rails.cache.delete("products:#{id}")
    Rails.cache.delete_matched("products:list:*")
  end
end
```

### Rate Limiting

```ruby
# app/controllers/concerns/rate_limitable.rb
module RateLimitable
  extend ActiveSupport::Concern

  def rate_limit!(key:, limit:, period:)
    redis = Redis.current
    count = redis.incr(key)
    redis.expire(key, period) if count == 1

    if count > limit
      render json: { error: "Rate limit exceeded" }, status: :too_many_requests
    end
  end
end

# Usage
class Api::V1::SearchController < ApplicationController
  include RateLimitable

  def index
    rate_limit!(key: "search:#{request.ip}", limit: 100, period: 60)
    # ...
  end
end
```
{%- endif %}

---

{%- if values.jobProcessor != "none" %}

## Background Jobs

{%- if values.jobProcessor == "sidekiq" %}

### Sidekiq Job

```ruby
# app/jobs/send_notification_job.rb
class SendNotificationJob
  include Sidekiq::Job

  sidekiq_options queue: :default, retry: 3

  def perform(user_id, message)
    user = User.find(user_id)
    NotificationService.send(user: user, message: message)
  end
end

# Enqueue
SendNotificationJob.perform_async(user.id, "Welcome!")

# Delayed
SendNotificationJob.perform_in(5.minutes, user.id, "Reminder")

# Scheduled
SendNotificationJob.perform_at(tomorrow_9am, user.id, "Daily digest")
```

### Batch Jobs

```ruby
class BulkEmailJob
  include Sidekiq::Job

  def perform(user_ids)
    User.where(id: user_ids).find_each do |user|
      SendEmailJob.perform_async(user.id)
    end
  end
end
```
{%- endif %}

{%- if values.jobProcessor == "solid-queue" %}

### Solid Queue Job

```ruby
# app/jobs/send_notification_job.rb
class SendNotificationJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(user_id, message)
    user = User.find(user_id)
    NotificationService.send(user: user, message: message)
  end
end

# Enqueue
SendNotificationJob.perform_later(user.id, "Welcome!")

# Delayed
SendNotificationJob.set(wait: 5.minutes).perform_later(user.id, "Reminder")
```
{%- endif %}
{%- endif %}

---

## External API Integration

### HTTP Client

```ruby
# app/clients/payment_client.rb
class PaymentClient
  include HTTParty
  base_uri ENV.fetch("PAYMENT_API_URL")

  def initialize
    @headers = {
      "Authorization" => "Bearer #{ENV.fetch('PAYMENT_API_KEY')}",
      "Content-Type" => "application/json"
    }
  end

  def charge(amount:, currency:, source:)
    response = self.class.post(
      "/v1/charges",
      headers: @headers,
      body: { amount: amount, currency: currency, source: source }.to_json
    )

    handle_response(response)
  end

  private

  def handle_response(response)
    case response.code
    when 200..299
      response.parsed_response
    when 401
      raise AuthenticationError, "Invalid API key"
    when 422
      raise ValidationError, response.parsed_response["error"]
    else
      raise ApiError, "Payment API error: #{response.code}"
    end
  end
end
```

### With Retry

```ruby
class PaymentClient
  MAX_RETRIES = 3
  RETRY_DELAY = 1

  def charge_with_retry(amount:, currency:, source:)
    retries = 0

    begin
      charge(amount: amount, currency: currency, source: source)
    rescue ApiError => e
      retries += 1
      if retries <= MAX_RETRIES
        sleep(RETRY_DELAY * retries)
        retry
      end
      raise
    end
  end
end
```

---

## Custom Middleware

### Request Timing

```ruby
# lib/middleware/request_timing.rb
class RequestTiming
  def initialize(app)
    @app = app
  end

  def call(env)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    status, headers, response = @app.call(env)
    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

    headers["X-Response-Time"] = "#{(duration * 1000).round}ms"
    [status, headers, response]
  end
end

# config/application.rb
config.middleware.use RequestTiming
```

### Tenant Middleware

```ruby
# lib/middleware/tenant_context.rb
class TenantContext
  def initialize(app)
    @app = app
  end

  def call(env)
    tenant_id = env["HTTP_X_TENANT_ID"]

    if tenant_id.blank?
      return [400, { "Content-Type" => "application/json" },
              ['{"error": "X-Tenant-ID header required"}']]
    end

    Current.tenant_id = tenant_id
    @app.call(env)
  ensure
    Current.tenant_id = nil
  end
end
```

---

## Testing Patterns

### Request Specs

```ruby
RSpec.describe "Api::V1::Products" do
  describe "POST /api/v1/products" do
    context "with valid params" do
      it "creates and returns product" do
        post "/api/v1/products", params: { product: valid_attributes }

        expect(response).to have_http_status(:created)
        expect(json_response["product"]["name"]).to eq(valid_attributes[:name])
      end
    end

    context "with invalid params" do
      it "returns validation errors" do
        post "/api/v1/products", params: { product: { name: "" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["errors"]).to include("Name can't be blank")
      end
    end
  end
end
```

### Service Specs

```ruby
RSpec.describe Products::CreateService do
  describe "#call" do
    subject { described_class.call(params: params) }

    context "with valid params" do
      let(:params) { { name: "Test", price: 9.99 } }

      it "returns success" do
        expect(subject).to be_success
        expect(subject.data).to be_a(Product)
      end
    end

    context "with invalid params" do
      let(:params) { { name: "" } }

      it "returns failure" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Name can't be blank")
      end
    end
  end
end
```

### Mocking External APIs

```ruby
RSpec.describe PaymentService do
  describe "#charge" do
    before do
      stub_request(:post, "https://api.payment.com/v1/charges")
        .to_return(status: 200, body: { id: "ch_123" }.to_json)
    end

    it "charges successfully" do
      result = described_class.charge(amount: 1000, currency: "usd")
      expect(result["id"]).to eq("ch_123")
    end
  end
end
```
