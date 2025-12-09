require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Do not reload between tests
  config.enable_reloading = false

  # Eager load for CI
  config.eager_load = ENV["CI"].present?

  # Show full error reports
  config.consider_all_requests_local = true

  # Disable caching
  config.cache_store = :null_store
  config.action_controller.perform_caching = false

  # Render errors instead of raising
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Logging
  config.log_level = :warn

  # Active Job
  config.active_job.queue_adapter = :test

  {%- if values.database != "none" %}
  # Active Record
  config.active_record.encryption.primary_key = "test-primary-key"
  config.active_record.encryption.deterministic_key = "test-deterministic-key"
  config.active_record.encryption.key_derivation_salt = "test-key-derivation-salt"
  {%- endif %}
end
