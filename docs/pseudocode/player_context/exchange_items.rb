class ExchangeItems
    def execute(requester, params)        
        filed = Filed.new()                 
        unless filed.surviving?(params[:exchang_partner_player_id]) {
            return {status: false, error_id: ERROR.NOT_SURVIVOR}
        }

        self.requester_inventory = Inventory.fetch_by_player(params[:exchang_target_player_id])
        self.partener_inventory = Inventory.fetch_by_player(params[:exchang_target_player_id])

        requester_item_stocks = build_item_stocks(requestr_params)
        partener_item_stocks = build_item_stocks(partner_params)

        conditions_status = conditions_of_exchange_have_been_established?(requester_item_stocks, partener_item_stocks)
        unless conditions_status[:status] {
            return {error_id: conditions_status[:error_id]}
        }        
                
        ActiveRecord::Base.transaction do
            self.requester_inventory.pass_items(item_stock, partner)        
            self.partener_inventory.pass_items(item_stock, requester)        
        end                

        return {exchanged_items: partener_item_stocks}
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

    def build_item_stocks(params)
        ...
    end
    

end

# テストケース
# 正常ケース
# 交換するアイテム分のポイントがある場合

# 異常ケース
# 交換するアイテム分のポイントがパートナーにない場合
# パートナーが生存していない場合
# 交換しようとしたアイテムが存在しない場合