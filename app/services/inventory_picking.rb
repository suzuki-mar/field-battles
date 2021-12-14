# frozen_string_literal: true

class InventoryPicking
  def add!(inventory, name, count)
    @inventory = inventory
    errors = []

    item = Item.find_by(name: name)
    errors << Error.build_with_message(I18n.t('error_message.item.nonexistent_name', name: name)) if item.nil?
    stock = ItemStock.find_or_initialize_by(player_id: inventory.player_id, item: item)
    stock.stock_count = count if stock.new_record?
    errors << Error.build_with_active_record(stock) unless stock.validate

    return Error.merge(errors) if errors.present?

    if stock.new_record?
      stock.save!
    else
      stock.add_stock!(count)
    end

    stock
  end

  def take_out!(inventory, name, count)
    @inventory = inventory

    item = Item.where(name: name).first
    stock = inventory.stocks.where(item: item).first

    if stock.nil?
      return Error.build_with_message(I18n.t('error_message.inventory.take_out.unregistered_item', name: name))
    end

    if stock.stock_count < count
      i18n_key = 'error_message.inventory.take_out.many_more_than_registered_quantity'
      return Error.build_with_message(I18n.t(i18n_key, count: stock.stock_count))
    end

    stock.reduce_stock!(count)
    { name: name, count: count }
  end

  private

  attr_accessor :inventory
end
