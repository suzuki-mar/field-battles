# frozen_string_literal: true

class InventoryControl
  def add(inventory, name, count)
    setup(inventory, name)

    add_error_unless_survivor

    errors << Error.build_with_message(I18n.t('error_message.item.nonexistent_name', name: name)) if target_item.nil?
    stock = ItemStock.find_or_initialize_by(player_id: inventory.player_id, item: target_item)

    if stock.new_record?
      register_new_item(stock, count)
    else
      increase_stock_count(stock, count)
    end
  end

  def take_out(inventory, name, count)
    setup(inventory, name)

    add_error_unless_survivor

    stock = inventory.stocks.where(item: target_item).first
    add_error_if_cannot_take_out(name, stock, count)

    return Error.merge(errors) if errors.present?

    stock.reduce_stock!(count)
    { name: name, count: count }
  end

  private

  def setup(inventory, name)
    @inventory = inventory
    @errors = []
    @target_item = Item.find_by(name: name)
  end

  def add_error_unless_survivor
    return if Player.survivor?(inventory.player_id)

    error_key = 'error_message.inventory.inventory_control.executed_by_nonsurvivors'
    errors << Error.build_with_message(I18n.t(error_key))
  end

  def register_new_item(stock, count)
    stock.stock_count = count
    errors << Error.build_with_active_record(stock) unless stock.validate

    return Error.merge(errors) if errors.present?

    stock.save!
  end

  def increase_stock_count(stock, count)
    errors << Error.build_with_active_record(stock) unless stock.validate
    return Error.merge(errors) if errors.present?

    stock.add_stock!(count)
  end

  def add_error_if_cannot_take_out(name, stock, count)
    if stock.nil?
      errors << Error.build_with_message(I18n.t('error_message.inventory.take_out.unregistered_item', name: name))
      return Error.merge(errors)
    end

    return if stock.stock_count >= count

    i18n_key = 'error_message.inventory.take_out.many_more_than_registered_quantity'
    errors << Error.build_with_message(I18n.t(i18n_key, count: stock.stock_count))
  end

  attr_accessor :inventory, :errors, :target_item
end