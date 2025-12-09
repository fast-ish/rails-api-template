# Puma configuration file

# Thread pool
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }.to_i
threads min_threads_count, max_threads_count

# Workers (processes)
worker_count = ENV.fetch("WEB_CONCURRENCY", 2).to_i
workers worker_count if worker_count > 1

# Preload app for Copy-on-Write memory savings
preload_app!

# Port
port ENV.fetch("PORT", 3000)

# Environment
environment ENV.fetch("RAILS_ENV", "development")

# PID file
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Hooks
on_worker_boot do
  {%- if values.database != "none" %}
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  {%- endif %}
  {%- if values.cache == "elasticache-redis" or values.jobProcessor == "sidekiq" %}
  # Reconnect to Redis
  {%- endif %}
end

# Logging
quiet false if ENV.fetch("RAILS_LOG_TO_STDOUT", "true") == "true"
