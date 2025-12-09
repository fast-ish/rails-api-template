module Api
  module V1
    class BaseController < ApplicationController
      before_action :set_default_format

      private

      def set_default_format
        request.format = :json
      end

      {%- if values.pagination == "pagy" %}
      def paginate(collection)
        pagy, records = pagy(collection)
        pagy_headers_merge(pagy)
        records
      end

      def pagination_meta(pagy)
        {
          current_page: pagy.page,
          total_pages: pagy.pages,
          total_count: pagy.count,
          per_page: pagy.items
        }
      end
      {%- endif %}

      {%- if values.pagination == "kaminari" %}
      def paginate(collection)
        page = params[:page]&.to_i || 1
        per_page = [params[:per_page]&.to_i || 20, 100].min
        collection.page(page).per(per_page)
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
      {%- endif %}
    end
  end
end
