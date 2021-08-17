# frozen_string_literal: true

module PlayerContexts
  class ExchangeItems
    def execute(requester, params)
      @params = params
      validator = Usecase::ExchangeItemsValidator.new

      return { success: false, error_keys: validator.error_keys } unless validator.valid?(params)

      @requester_inventory = Inventory.fetch_by_player_id(requester.id)
      @partener_inventory = Inventory.fetch_by_player_id(params[:partner_player_id])

      ActiveRecord::Base.transaction do
        requestor_presents_items
        partener_presents_items
      end

      { sucess: true }
    end

    private

    attr_reader :requester_inventory, :partener_inventory, :params, :item_name_and_points

    def requestor_presents_items
      params[:requeser_items].each do |item|
        partener_inventory.add(item[:name], item[:count])
        requester_inventory.take_out(item[:name], item[:count])
      end
    end

    def partener_presents_items
      params[:partner_items].each do |item|
        requester_inventory.add(item[:name], item[:count])
        partener_inventory.take_out(item[:name], item[:count])
      end
    end
  end
end
