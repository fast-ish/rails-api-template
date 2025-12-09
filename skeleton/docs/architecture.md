# Architecture

## System Overview

```mermaid
flowchart TB
    subgraph Clients
        WEB[Web App]
        MOBILE[Mobile App]
    end

    subgraph API["${{values.name}}"]
        CTRL[Controllers]
        SVC[Services]
        SER[Serializers]
        {%- if values.database != "none" %}
        MODEL[Models]
        {%- endif %}
    end

    {%- if values.database != "none" %}
    subgraph Data
        DB[(Aurora)]
    end
    {%- endif %}

    {%- if values.cache == "elasticache-redis" %}
    subgraph Cache
        REDIS[(Redis)]
    end
    {%- endif %}

    subgraph Observability
        GRAFANA[Grafana Stack]
    end

    Clients --> CTRL
    CTRL --> SVC
    SVC --> SER
    {%- if values.database != "none" %}
    SVC --> MODEL
    MODEL --> DB
    {%- endif %}
    {%- if values.cache == "elasticache-redis" %}
    SVC --> REDIS
    {%- endif %}
    API --> GRAFANA
```

## Request Flow

```mermaid
sequenceDiagram
    participant Client
    participant Controller
    participant Service
    participant Serializer
    {%- if values.database != "none" %}
    participant Model
    participant DB
    {%- endif %}

    Client->>Controller: HTTP Request
    Controller->>Service: call()
    {%- if values.database != "none" %}
    Service->>Model: query/mutate
    Model->>DB: SQL
    DB-->>Model: rows
    Model-->>Service: objects
    {%- endif %}
    Service-->>Controller: result
    Controller->>Serializer: serialize
    Serializer-->>Controller: JSON
    Controller-->>Client: HTTP Response
```

## Directory Structure

```
app/
├── controllers/
│   ├── application_controller.rb
│   └── api/
│       └── v1/
│           └── base_controller.rb
├── models/
│   └── application_record.rb
├── serializers/
│   └── base_serializer.rb
├── services/
│   └── application_service.rb
└── jobs/
    └── application_job.rb

config/
├── application.rb
├── routes.rb
├── database.yml
├── puma.rb
└── initializers/
    ├── opentelemetry.rb
    └── cors.rb

spec/
├── spec_helper.rb
├── rails_helper.rb
├── requests/
├── models/
├── services/
└── factories/
```

## Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Ruby ${{values.rubyVersion}} |
| Framework | Rails ${{values.railsVersion}} |
| Web Server | Puma |
{%- if values.database == "aurora-postgresql" %}
| Database | Aurora PostgreSQL |
{%- endif %}
{%- if values.database == "aurora-mysql" %}
| Database | Aurora MySQL |
{%- endif %}
{%- if values.cache == "elasticache-redis" %}
| Cache | ElastiCache Redis |
{%- endif %}
{%- if values.jobProcessor == "sidekiq" %}
| Jobs | Sidekiq |
{%- endif %}
{%- if values.jobProcessor == "solid-queue" %}
| Jobs | Solid Queue |
{%- endif %}
| Serializer | ${{values.serializer | title}} |
| Observability | OpenTelemetry + Grafana |
| Testing | RSpec |
