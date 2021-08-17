# frozen_string_literal: true

class ItemStockSerializer
  include JSONAPI::Serializer

  attribute :item do |item_stock, _params|
    ItemSerializer.new(item_stock.item).serializable_hash
  end
end
