# frozen_string_literal: true

class Inventory
  attr_reader :player_id, :stocks, :errors

  def add!(name, count)
    result = inventory_control.add(self, name, count)
    processing_after_inventory_control!(result)
  end

  def take_out!(name, count)
    result = inventory_control.take_out(self, name, count)
    processing_after_inventory_control!(result)
  end

  def use!(name)
    result = inventory_control.take_out(self, name, 1)
    processing_after_inventory_control!(result)
  end

  def has_item?(name)
    inventory_control.has_item?(self, name)
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
      raise ActiveRecord::RecordNotFound  if stocks.blank?

      new(player_id, stocks)
    end

    def build_with_empty_item_stocks(player_id)
      Inventory.new(player_id, [])
    end

    def register_for_newcomer!(player_id, stock_params)
      inventory = Inventory.new(player_id, [])
      stock_params.each do |param|
        inventory.add!(param[:name], param[:count])
      end
      inventory.reload
      inventory
    end
  end

  private

  attr_reader :inventory_control

  def processing_after_inventory_control!(result)
    if result.instance_of?(Error)
      @errors = [result]
      raise ActiveRecord::Rollback
    end

    reload
    result
  end

  protected

  def initialize(player_id, stocks)
    @player_id = player_id
    @stocks = stocks
    @errors = []
    @inventory_control = InventoryControl.new
  end
end
