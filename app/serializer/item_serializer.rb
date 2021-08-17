class ItemSerializer
  include JSONAPI::Serializer
  
  attributes :point, :name
end
