require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Reload code on every request
  config.enable_reloading = true

  # Do not eager load code on boot
  config.eager_load = false

  # Show full error reports
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Cache
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  {%- if values.database != "none" %}
  # Active Record
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  {%- endif %}

  # Logging
  config.log_level = :debug

  # Action Cable
  {%- if values.actionCable %}
  config.action_cable.disable_request_forgery_protection = true
  {%- endif %}

  # Hosts
  config.hosts.clear
end
