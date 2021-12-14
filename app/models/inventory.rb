# frozen_string_literal: true

class Inventory
  attr_reader :player_id, :stocks, :errors

  def add!(name, count)
    result = InventoryPicking.new.add!(self, name, count)
    
    if result.instance_of?(Error) 
      @errors = [result]
      raise ActiveRecord::Rollback
    end

    result
  end

  def take_out!(name, count)
    result = InventoryPicking.new.take_out!(self, name, count)

    if result.instance_of?(Error) 
      @errors = [result]
      raise ActiveRecord::Rollback
    end

    result    

  end

  def reload
    @stocks = ItemStock.where(player_id: player_id)
  end

  def stock_count_by_name(name)
    stock = stocks.includes(:item).find do |s|
      s.item.name == name
    end

    return 0 if stock.nil?

    stock.stock_count
  end

  def all_stock_name_and_count
    stocks.map do |s|
      { name: s.name, count: s.stock_count }
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
        inventory.add!(param[:name], param[:count])
      end
      inventory.reload
      inventory
    end

    def fetch_all_survivor_inventories
      players = Player.only_survivor
      stocks = ItemStock.where(player: players)

      grouped_stocks = build_grouped_stocks(players, stocks)

      grouped_stocks.map do |player_id, ss|
        new(player_id, ss)
      end
    end

    def fetch_all_not_survivor_inventories
      players = Player.where(status: [Player.statuses[:zombie], Player.statuses[:death]])
      stocks = ItemStock.where(player: players)

      grouped_stocks = build_grouped_stocks(players, stocks)

      grouped_stocks.map do |player_id, ss|
        new(player_id, ss)
      end
    end
  end

  protected

  def initialize(player_id, stocks)
    @player_id = player_id
    @stocks = stocks   
    @errors = []
  end

  class << self
    def build_grouped_stocks(players, stocks)
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
end
