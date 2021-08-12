# frozen_string_literal: true

class MoveWhereabouts
  def execute
    fields = Fileds.new
    survivors = fields.fetch_survivors
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
