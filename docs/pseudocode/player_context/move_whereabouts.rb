# frozen_string_literal: true

class MoveWhereabouts
  def execute
    fields = Fileds.new
    survivors = fields.fetch_survivors

    survivors.each{|survivor|
      survivor.assign_next_locations
      
      while(true) {
        next if (fields.can_move?(survivor)) 
        survivor.assign_next_locations  
      }        
    }

    ActiveRecord::Base.transaction do
      fields.determine_location_to_move!(survivors)
    end                
    
    return true
  end
end

# テストケース
# 生存者が存在している場合
# エラーケース
# 生存者が存在していない場合
