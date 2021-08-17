# frozen_string_literal: true

class ItemSerializer
  include JSONAPI::Serializer

  attributes :point, :name
end
