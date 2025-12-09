class ApplicationJob < ActiveJob::Base
  # Retry on standard failures
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  # Discard jobs with invalid arguments
  discard_on ActiveJob::DeserializationError

  {%- if values.jobProcessor == "sidekiq" %}
  # Sidekiq options
  # sidekiq_options retry: 3, queue: :default
  {%- endif %}
end
