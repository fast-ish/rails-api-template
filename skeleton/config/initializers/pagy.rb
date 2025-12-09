{%- if values.pagination == "pagy" %}
require "pagy/extras/headers"
require "pagy/extras/metadata"
require "pagy/extras/overflow"

Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:max_items] = 100
Pagy::DEFAULT[:overflow] = :last_page
{%- endif %}
