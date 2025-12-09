require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings
  config.eager_load = true

  # Full error reports are disabled
  config.consider_all_requests_local = false

  # Cache
  {%- if values.cache == "elasticache-redis" %}
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    expires_in: 1.hour,
    namespace: "${{values.name}}"
  }
  {%- else %}
  config.cache_store = :memory_store, { size: 64.megabytes }
  {%- endif %}

  # Action Cable
  {%- if values.actionCable %}
  config.action_cable.mount_path = "/cable"
  config.action_cable.url = ENV.fetch("ACTION_CABLE_URL", "wss://#{ENV.fetch('HOST', 'localhost')}/cable")
  config.action_cable.allowed_request_origins = [
    ENV.fetch("CORS_ORIGINS", "*")
  ]
  {%- endif %}

  # Logging
  config.log_level = ENV.fetch("LOG_LEVEL", "info").to_sym
  config.log_tags = [:request_id]

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Active Record
  {%- if values.database != "none" %}
  config.active_record.dump_schema_after_migration = false
  {%- endif %}

  # Active Job
  {%- if values.jobProcessor == "sidekiq" %}
  config.active_job.queue_adapter = :sidekiq
  {%- elif values.jobProcessor == "solid-queue" %}
  config.active_job.queue_adapter = :solid_queue
  {%- endif %}

  # Force SSL
  config.force_ssl = ENV.fetch("FORCE_SSL", "true") == "true"

  # Host authorization
  config.hosts << ENV.fetch("HOST", "${{values.name}}.example.com")
  config.hosts << /.*\.amazonaws\.com/
end
