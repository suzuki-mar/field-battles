#  id                        :integer          not null, primary key
#  age                       :integer          not null
#  counting_to_become_zombie :integer          not null
#  counting_to_starvation    :integer          not null
#  current_lat               :float            not null
#  current_lon               :float            not null
#  name                      :string           not null
#  status                    :integer          not null

class PlayerSerializer
  include JSONAPI::Serializer
  
  attributes :age, :counting_to_become_zombie, :name
  
  attribute :current_location do |player|
    {lon: player.current_lon, lat: player.current_lat}
  end

  attribute :inventory do |player|
    inventory = Inventory.fetch_by_player_id(player.id)
    
    serialized_stocks = inventory.stocks.map do |stock|
      ItemStockSerializer.new(stock).serializable_hash
    end

    {item_stocks: serialized_stocks}
  end
end

  