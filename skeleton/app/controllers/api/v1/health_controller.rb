module Api
  module V1
    class HealthController < BaseController
      def show
        render json: {
          status: "ok",
          timestamp: Time.current.iso8601,
          version: ENV.fetch("OTEL_SERVICE_VERSION", "1.0.0")
        }
      end
    end
  end
end
