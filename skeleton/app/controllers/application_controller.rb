class ApplicationController < ActionController::API
  {%- if values.pagination == "pagy" %}
  include Pagy::Backend
  {%- endif %}

  rescue_from StandardError, with: :handle_internal_error
  rescue_from ActionController::ParameterMissing, with: :handle_bad_request
  {%- if values.database != "none" %}
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity
  {%- endif %}

  private

  def handle_internal_error(exception)
    Rails.logger.error("Internal error: #{exception.message}")
    Rails.logger.error(exception.backtrace.first(10).join("\n"))

    render json: {
      error: "internal_server_error",
      message: Rails.env.production? ? "An unexpected error occurred" : exception.message
    }, status: :internal_server_error
  end

  def handle_bad_request(exception)
    render json: {
      error: "bad_request",
      message: exception.message
    }, status: :bad_request
  end

  {%- if values.database != "none" %}
  def handle_not_found(exception)
    render json: {
      error: "not_found",
      message: exception.message
    }, status: :not_found
  end

  def handle_unprocessable_entity(exception)
    render json: {
      error: "unprocessable_entity",
      message: exception.record.errors.full_messages.join(", ")
    }, status: :unprocessable_entity
  end
  {%- endif %}
end
