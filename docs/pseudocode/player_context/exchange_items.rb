class ExchangeItems
    def execute(requester_id, params)
        filed = Filed.new()         
        self.requester_inventory = Inventory.fetch_by_player_id(params[:exchang_target_player_id])

        exchangeable = can_be_exchanged?
        unless exchangeable[:status] {
            return {error_id: exchangeable[:error_id]}
        }
        
        self.partener_inventory = Inventory.fetch_by_player_id(params[:exchang_target_player_id])
        
        requester_items = find_requester_items        
        partener_items = find_partener_items(requester_items params[:exchang_target_player_id])

        ActiveRecord::Base.transaction do
            Trade.execute(requester_items, partener_items)
        end                

        return {partener_items: partener_items}
    end

    private 
    attr_reader :item_params, :requester_id, :requester_inventory, :partener_inventory, :

    def exists_items_to_trade?

    end

    def can_be_exchanged?
        unless filed.surviving?(params[:exchang_partner_player_id]) {
            return {status: false, error_id: ERROR.NOT_SURVIVOR}
        }
        
        item_counts = ...
        exists_items_to_trade = self.requester_inventory.exists_items(item_counts)

        unless exists_items_to_trade? {
            return {status: false, error_id: ERROR.NO_ITEMS_TO_EXCHANGE}
        }

        return {status: true}
    end


    def calc_requester_item_points
        requester_item_stocks = build_requester_item_stocks
        self.requester_inventory.calc_item_points_form_item_stocks(requester_item_stocks)        
    end

    def build_requester_item_stocks        
        self.item_params.map(|param| ItemStock.new(param[:count], param[:item][:id]))
    end
    
    def find_partener_items
        item_points = ItemPoint.creates_from_player_id(self.params[:exchang_target_player_id])    
    end

    def find_requester_items
        item_points = ItemPoint.creates_from_player_id(self.params[:exchang_target_player_id])    
    end

    def pass_requester_items(requester_item_points) 
        

    end

    

end

# パタメーター
# {
#     "exchang_target_player_id": 0,
#     "items": [
#       {
#         "count": 0,
#         "item": {
#           "id": "1",
#           "type": "first_aid_kit",
#           "effect_value": 5,
#           "point": 10
#         }
#       }
#     ]
#   }


# テストケース
# 正常ケース
# 交換するアイテム分のポイントがある場合

# 異常ケース
# 交換するアイテム分のポイントがパートナーにない場合
# パートナーが生存していない場合
# 交換しようとしたアイテムが存在しない場合