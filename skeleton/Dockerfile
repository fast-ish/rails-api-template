# syntax=docker/dockerfile:1
ARG RUBY_VERSION=${{values.rubyVersion}}
FROM ruby:${RUBY_VERSION}-slim as base

WORKDIR /app

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Build stage
FROM base as build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    {%- if values.database == "aurora-postgresql" %}
    libpq-dev \
    {%- endif %}
    {%- if values.database == "aurora-mysql" %}
    default-libmysqlclient-dev \
    {%- endif %}
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Runtime stage
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    {%- if values.database == "aurora-postgresql" %}
    libpq5 \
    {%- endif %}
    {%- if values.database == "aurora-mysql" %}
    default-mysql-client \
    {%- endif %}
    && rm -rf /var/lib/apt/lists/*

# Copy built artifacts
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Create non-root user
RUN useradd --create-home --shell /bin/bash rails && \
    chown -R rails:rails /app
USER rails

# OpenTelemetry configuration
ARG OTEL_SERVICE_VERSION="1.0.0"
ENV OTEL_SERVICE_VERSION=${OTEL_SERVICE_VERSION}
LABEL io.grafana.service="${{values.name}}"

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
