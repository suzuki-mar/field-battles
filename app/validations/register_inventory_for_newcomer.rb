class RegisterInventoryForNewcomer
  attr_reader :errors
  
  def initialize
    @errors = []
  end

  def validate(player_id, stock_params)
    unless Player.newcomer?(player_id)
      error_key = 'error_message.inventory.register_inventory_for_non-newcomer'
      errors << Error.build_with_message(I18n.t(error_key))    
    end
          
    existent_names = Item.fetch_all_name_and_point.pluck(:name)

    stock_params.each do |param|
      param_error = validate_stock_param(param, existent_names)
      errors << param_error if param_error.present?
    end

    errors
  end

  private 
  def validate_stock_param(param, existent_names)
    param_errors = []

    unless existent_names.include?(param[:name])
      error_message = I18n.t("error_message.item.nonexistent_name", name: param[:name])
      param_errors << Error.build_with_message(error_message)            
    end
    
    unless ItemStock.valid_stock_count?(param[:count])
      error_message = I18n.t("error_message.item_stock.stock_count")
      param_errors << Error.build_with_message(error_message)            
    end        

    return if param_errors.blank?

    Error.merge(param_errors)
  end
end