require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = ENV.fetch("OTEL_SERVICE_NAME", "${{values.name}}")
  c.service_version = ENV.fetch("OTEL_SERVICE_VERSION", "1.0.0")

  # Configure OTLP exporter (sends to Grafana Tempo/Alloy)
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: ENV.fetch("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4318/v1/traces")
      )
    )
  )

  # Auto-instrumentation
  c.use_all({
    "OpenTelemetry::Instrumentation::Rails" => { enable_recognize_route: true },
    "OpenTelemetry::Instrumentation::Rack" => { record_frontend_span: true },
    {%- if values.database == "aurora-postgresql" %}
    "OpenTelemetry::Instrumentation::PG" => { peer_service: "postgresql" },
    {%- endif %}
    {%- if values.database == "aurora-mysql" %}
    "OpenTelemetry::Instrumentation::Mysql2" => { peer_service: "mysql" },
    {%- endif %}
    "OpenTelemetry::Instrumentation::ActiveRecord" => {},
    {%- if values.cache == "elasticache-redis" or values.jobProcessor == "sidekiq" %}
    "OpenTelemetry::Instrumentation::Redis" => { peer_service: "redis" },
    {%- endif %}
    {%- if values.jobProcessor == "sidekiq" %}
    "OpenTelemetry::Instrumentation::Sidekiq" => {},
    {%- endif %}
    "OpenTelemetry::Instrumentation::Net::HTTP" => {},
    "OpenTelemetry::Instrumentation::Faraday" => {}
  })
end
