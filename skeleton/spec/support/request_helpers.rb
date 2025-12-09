module RequestHelpers
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  def json_headers
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  {%- if values.authentication == "devise-jwt" %}
  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    json_headers.merge("Authorization" => "Bearer #{token}")
  end
  {%- endif %}
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
