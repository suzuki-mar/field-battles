class ItemStockSerializer
  include JSONAPI::Serializer
  
  attribute :item do |item_stock, params|
    ItemSerializer.new(item_stock.item).serializable_hash
  end
end
