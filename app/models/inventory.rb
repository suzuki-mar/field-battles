class Inventory
  attr_reader :player_id, :stocks

  def add(name, count)
    if has_name_item?(name)
      item = Item.where(name: name).first
      stock = self.stocks.where(item: item).first      
      stock.add_stock!(count)      
      return
    end

    item = Item.find_by_name(name)
    ItemStock.create(player_id: player_id, item: item, stock_count: count)
  end

  def take_out(name, count)
    item = Item.where(name: name).first
    stock = self.stocks.where(item: item).first      
    stock.reduce_stock!(count)
    return {name: name, count: count}
  end

  def reload 
    @stocks = ItemStock.where(player_id: self.player_id)
  end

  def stock_count_by_name(name)    
    traded_stock = self.stocks.includes(:item).find do |stock|
      stock.item.name == name
    end
    
    traded_stock.stock_count    
  end

  class << self
    def fetch_by_player_id(player_id)
      stocks = ItemStock.where(player_id: player_id)
      
      self.new(player_id, stocks)
    end
  end

  protected 
  def initialize(player_id, stocks)
    @player_id = player_id
    @stocks = stocks
  end

  private 
  def has_name_item?(name)
    return self.stocks.includes(:item).any? do |stock|
      stock.item.name == name
    end
  end


end