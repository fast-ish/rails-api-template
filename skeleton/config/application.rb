require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
{%- if values.database != "none" %}
require "active_record/railtie"
{%- endif %}
require "action_controller/railtie"
{%- if values.actionCable %}
require "action_cable/engine"
{%- endif %}
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module ${{values.name | replace("-", "_") | title | replace("_", "")}}
  class Application < Rails::Application
    config.load_defaults ${{values.railsVersion}}

    # API-only mode
    config.api_only = true

    # Time zone
    config.time_zone = "UTC"

    # Autoload paths
    config.autoload_paths += %W[#{config.root}/app/services]
    config.autoload_paths += %W[#{config.root}/app/serializers]

    # Active Job adapter
    {%- if values.jobProcessor == "sidekiq" %}
    config.active_job.queue_adapter = :sidekiq
    {%- elif values.jobProcessor == "solid-queue" %}
    config.active_job.queue_adapter = :solid_queue
    {%- else %}
    config.active_job.queue_adapter = :async
    {%- endif %}

    # Logging
    config.log_level = ENV.fetch("LOG_LEVEL", "info").to_sym
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Logstash.new
    config.lograge.custom_options = lambda do |event|
      span = OpenTelemetry::Trace.current_span
      {
        trace_id: span.context.hex_trace_id,
        span_id: span.context.hex_span_id,
        service: ENV.fetch("OTEL_SERVICE_NAME", "${{values.name}}"),
        params: event.payload[:params].except("controller", "action", "format"),
        request_id: event.payload[:request_id]
      }
    end

    # Generators
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.orm :active_record, primary_key_type: :uuid if config.respond_to?(:active_record)
    end
  end
end
