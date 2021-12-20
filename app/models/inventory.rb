# frozen_string_literal: true

class Inventory
  attr_reader :player_id, :stocks, :errors

  def add!(name, count)
    result = InventoryControl.new.add(self, name, count)

    if result.instance_of?(Error)
      @errors = [result]
      raise ActiveRecord::Rollback
    end

    result
  end

  def take_out!(name, count)
    result = InventoryControl.new.take_out(self, name, count)

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
    def validate_for_newcomer(player_id, stock_params)
      validation = RegisterInventoryForNewcomer.new
      validation.validate(player_id, stock_params)
    end

    def fetch_by_player_id(player_id)
      stocks = ItemStock.where(player_id: player_id)

      new(player_id, stocks)
    end

    def register_for_newcomer!(player_id, stock_params)
      inventory = Inventory.new(player_id, [])
      stock_params.each do |param|
        inventory.add!(param[:name], param[:count])
      end
      inventory.reload
      inventory
    end

    # クライアントへのインターフェースを変えないが肥大化の対策をするため移譲する
    def fetch_all_survivor_inventories
      TradeCenter.new.fetch_survivor_inventories
    end

    def fetch_all_not_survivor_inventories
      TradeCenter.new.fetch_not_survivor_inventories
    end
  end

  protected

  def initialize(player_id, stocks)
    @player_id = player_id
    @stocks = stocks
    @errors = []
  end
end
