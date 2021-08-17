# frozen_string_literal: true

class Inventory
  attr_reader :player_id, :stocks

  def add(name, count)
    if has_name_item?(name)
      item = Item.where(name: name).first
      stock = stocks.where(item: item).first
      stock.add_stock!(count)
      return
    end

    item = Item.find_by(name: name)
    ItemStock.create(player_id: player_id, item: item, stock_count: count)
  end

  def take_out(name, count)
    item = Item.where(name: name).first
    stock = stocks.where(item: item).first
    stock.reduce_stock!(count)
    { name: name, count: count }
  end

  def reload
    @stocks = ItemStock.where(player_id: player_id)
  end

  

  def stock_count_by_name(name)
    stock = stocks.includes(:item).find do |stock|
      stock.item.name == name
    end

    return 0 if stock.nil?

    stock.stock_count
  end

  def all_stock_name_and_count
    stocks.map do |s|
      {name: s.name, count: s.stock_count}
    end
  end

  class << self
    def fetch_by_player_id(player_id)
      stocks = ItemStock.where(player_id: player_id)

      new(player_id, stocks)
    end

    def create_for_newcomers(player_id, stock_params)
      inventory = new(player_id, [])
      stock_params.each do |param|
        inventory.add(param[:name], param[:count])
      end
      inventory.reload
      inventory
    end

    def fetch_all_survivor_inventories
      players = Player.only_survivor
      stocks = ItemStock.where(player: players)

      grouped_stocks = build_grouped_stocks(players, stocks)

      grouped_stocks.map do |player_id, stocks| 
        self.new(player_id, stocks)
      end
    end

    def fetch_all_not_survivor_inventories
      players = Player.where(status: [Player.statuses[:zombie], Player.statuses[:death]])
      stocks = ItemStock.where(player: players)

      grouped_stocks = build_grouped_stocks(players, stocks)

      grouped_stocks.map do |player_id, stocks| 
        self.new(player_id, stocks)
      end
    end
  end

  protected

  def initialize(player_id, stocks)
    @player_id = player_id
    @stocks = stocks
  end

  private

  def has_name_item?(name)
    return false if stocks.blank?

    stocks.includes(:item).any? do |stock|
      stock.item.name == name
    end
  end

  def self.build_grouped_stocks(players, stocks)
    grouped_stocks = {}
    players.map do |p|
      grouped_stocks[p.id] = []
    end

    stocks.each do |stock|
      grouped_stocks[stock.player_id].push(stock)
    end
    
    grouped_stocks
  end
end
