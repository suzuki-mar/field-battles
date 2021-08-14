module PlayerContexts
  class ExchangeItems
    def execute(requester, params)
      @params = params
      @requester_inventory = Inventory.fetch_by_player_id(requester.id)
      @partener_inventory = Inventory.fetch_by_player_id(params['partner_player_id'])

      ActiveRecord::Base.transaction do
        requestor_presents_items
        partener_presents_items
      end

      { sucess: true }
    end

    private

    attr_reader :requester_inventory, :partener_inventory, :params

    def requestor_presents_items
      params['requeser_items'].each do |item|
        partener_inventory.add(item['name'], item['count'])
        requester_inventory.take_out(item['name'], item['count'])
      end
    end

    def partener_presents_items
      params['partner_items'].each do |item|
        requester_inventory.add(item['name'], item['count'])
        partener_inventory.take_out(item['name'], item['count'])
      end
    end
  end
end
