Rails.application.routes.draw do
  # Health checks
  health_check_routes

  # API routes
  namespace :api do
    namespace :v1 do
      # Add your routes here
      # resources :users, only: [:index, :show, :create, :update, :destroy]
    end
  end

  {%- if values.jobProcessor == "sidekiq" %}
  # Sidekiq Web UI (protect in production)
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
  {%- endif %}

  {%- if values.actionCable %}
  # Action Cable
  mount ActionCable.server => "/cable"
  {%- endif %}
end
