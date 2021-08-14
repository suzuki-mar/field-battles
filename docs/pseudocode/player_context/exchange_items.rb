class ExchangeItems
    def execute(requester, params)        
        filed = Filed.new()                 
        unless filed.surviving?(params[:exchang_partner_player_id]) {
            return {status: false, error_id: ERROR.NOT_SURVIVOR}
        }

        #イベントリの読み込み

        conditions_status = conditions_of_exchange_have_been_established?(requester_item_stocks, partener_item_stocks)
        unless conditions_status[:status] {
            return {error_id: conditions_status[:error_id]}
        }        
                
        #アイテムの交換

        #戻り値
    end

    private 
    attr_reader :requester_id, :requester_inventory, :requester_item_stocks, :partener_inventory, :partener_item_stocks

    def conditions_of_exchange_have_been_established(requester_item_stocks, partener_item_stocks)
        
        unless self.requester_inventory.exists_items(requster_item_stocks)? {
            return {status: false, error_id: ERROR.UNEXITS_REQUSTER_ITEMS_TO_EXCHANGE}
        }
        
        unless self.partener_inventory.exists_items(partener_item_stocks)? {
            return {status: false, error_id: ERROR.UNEXITS_R_ITEMS_TO_EXCHANGE}
        }

        if (requester_item_stocks.same_point?(partener_item_stocks) {
            return {status: false, error_id: ERROR.DIFFRENT_POINTS_FOR_EXCHANGE_ITMES}
        }

        return {status: true}
    end

end