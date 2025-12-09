# ADR-0002: Use Grafana Stack for Observability

## Status

Accepted

## Date

2025-12

## Context

We need a comprehensive observability solution that provides APM, logging, and metrics for our Rails APIs. The solution should integrate seamlessly with our existing infrastructure and provide actionable insights using open standards.

## Decision Drivers

- APM with distributed tracing
- Log aggregation and correlation
- Metrics and dashboards
- Alerting capabilities
- Ruby/Rails integration quality
- Vendor neutrality via OpenTelemetry

## Considered Options

### Option 1: Grafana Stack (LGTM)

Grafana Loki, Grafana Tempo, Mimir/Prometheus with OpenTelemetry.

**Pros:**
- Open-source core components
- Vendor-neutral via OpenTelemetry
- Unified Grafana UI for all signals
- Cost-effective at scale
- Strong community support

**Cons:**
- More initial setup than SaaS solutions
- Self-managed infrastructure

### Option 2: Datadog

Full-stack observability platform.

**Pros:**
- Excellent Ruby/Rails integration
- Fully managed SaaS
- Unified platform

**Cons:**
- Cost at scale
- Vendor lock-in
- Proprietary instrumentation

### Option 3: New Relic

Application monitoring platform.

**Pros:**
- Strong APM capabilities
- Ruby agent available

**Cons:**
- Separate log aggregation needed
- Vendor lock-in

## Decision

We will use **Grafana Stack with OpenTelemetry** because:

1. Vendor-neutral instrumentation via OpenTelemetry
2. Unified Grafana UI for traces, logs, and metrics
3. Cost-effective at scale
4. Open-source components with enterprise support available
5. Organization-wide standardization on Grafana

## Consequences

### Positive

- Automatic instrumentation of Rails, ActiveRecord, Redis via OTEL
- Request traces correlated with logs via trace IDs
- Flexible dashboards in Grafana
- No vendor lock-in

### Negative

- Some infrastructure management required
- More configuration than SaaS alternatives

### Neutral

- Need to ensure OTEL_* environment variables are set
- Grafana Alloy/Agent runs as sidecar or DaemonSet

## Implementation Notes

```ruby
# config/initializers/opentelemetry.rb
require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = ENV.fetch("OTEL_SERVICE_NAME")
  c.use_all
end
```

### Key Metrics

- `http.server.request.duration`
- `http.server.active_requests`
- `db.client.operation.duration`

### Log Correlation

```ruby
# Lograge configuration
config.lograge.custom_options = lambda do |event|
  span = OpenTelemetry::Trace.current_span
  {
    trace_id: span.context.hex_trace_id,
    span_id: span.context.hex_span_id
  }
end
```

## Components

| Component | Purpose | Port |
|-----------|---------|------|
| Grafana Tempo | Distributed tracing | 4317/4318 |
| Grafana Loki | Log aggregation | 3100 |
| Prometheus/Mimir | Metrics | 9090 |
| Grafana | Visualization | 3000 |
| Grafana Alloy | Collector/Agent | 4317 |

## References

- [OpenTelemetry Ruby](https://opentelemetry.io/docs/languages/ruby/)
- [Grafana Tempo](https://grafana.com/docs/tempo/latest/)
- [Grafana Loki](https://grafana.com/docs/loki/latest/)
