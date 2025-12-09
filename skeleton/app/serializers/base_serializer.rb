{%- if values.serializer == "alba" %}
class BaseSerializer
  include Alba::Resource

  # Common attributes for all serializers
  # root_key :data

  # Transform keys to camelCase for JavaScript clients
  # transform_keys :lower_camel
end
{%- endif %}

{%- if values.serializer == "blueprinter" %}
class BaseSerializer < Blueprinter::Base
  # Common configuration for all serializers
end
{%- endif %}

{%- if values.serializer == "jsonapi-serializer" %}
class BaseSerializer
  include JSONAPI::Serializer

  # Common configuration for all serializers
end
{%- endif %}
