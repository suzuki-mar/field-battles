
class ExchangeItems
    

    def execute(requester_id, params)
        unless Items.survivor?(params[:exchang_partner_player_id]) {
            return {error_id: ERROR.NOT_SURVIVOR}
        }

        self.requester_inventory = Inventory.fetch_by_player_id(params[:exchang_target_player_id])
        self.partener_inventory = Inventory.fetch_by_player_id(params[:exchang_target_player_id])

        
        requester_item_points = calc_requester_item_points
        
        items_to_exchange = find_partener_items_to_exchange(params[:exchang_target_player_id])
        
        ActiveRecord::Base.transaction do
            pass_requester_items()
            mary.deposit(100)
        end        
        

        points = calc


    end

    private 
    attr_reader :item_params, :requester_id, :requester_inventory, :partener_inventory, :

    def calc_requester_item_points
        requester_item_stocks = build_requester_item_stocks
        self.requester_inventory.calc_item_points_form_item_stocks(requester_item_stocks)        
    end

    def build_requester_item_stocks        
        self.item_params.map(|param| ItemStock.new(param[:count], param[:item][:id]))
    end
    
    def find_partener_items_to_exchange
        item_points = ItemPoint.creates_from_player_id(self.params[:exchang_target_player_id])    
    end 

    def pass_requester_items(requester_item_points) 
        

    end

    

end

# テストケース
# 交換するアイテム分のポイントがある場合
# 交換するアイテム分のポイントがない場合
# 交換しようとしたユーザーが生存者ではない場合



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