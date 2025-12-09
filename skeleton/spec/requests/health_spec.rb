require "rails_helper"

RSpec.describe "Health Check", type: :request do
  describe "GET /health" do
    it "returns healthy status" do
      get "/health"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/health" do
    it "returns health status with version" do
      get "/api/v1/health", headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(json_response[:status]).to eq("ok")
      expect(json_response[:version]).to be_present
    end
  end
end
