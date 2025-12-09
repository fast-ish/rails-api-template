Rails.application.config.generators do |g|
  g.test_framework :rspec,
    fixtures: false,
    view_specs: false,
    helper_specs: false,
    routing_specs: false
  g.fixture_replacement :factory_bot, dir: "spec/factories"
  {%- if values.database != "none" %}
  g.orm :active_record, primary_key_type: :uuid
  {%- endif %}
end
