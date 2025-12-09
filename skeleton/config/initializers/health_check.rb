HealthCheck.setup do |config|
  config.uri = "health"
  config.success = "ok"
  config.http_status_for_error_text = 503
  config.http_status_for_error_object = 503

  # Standard checks
  config.standard_checks = []
  {%- if values.database != "none" %}
  config.standard_checks << "database"
  {%- endif %}
  {%- if values.cache == "elasticache-redis" %}
  config.standard_checks << "redis"
  {%- endif %}
  {%- if values.jobProcessor == "sidekiq" %}
  config.standard_checks << "sidekiq-redis"
  {%- endif %}

  # Full checks include migrations
  config.full_checks = config.standard_checks.dup
  {%- if values.database != "none" %}
  config.full_checks << "migrations"
  {%- endif %}

  # Max age for cached health check results
  config.max_age = 1
end
