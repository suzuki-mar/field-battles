# frozen_string_literal: true

class PlayerContexts::ExchangeItems
  def execute(requester, params)
      
      @requester_inventory = Inventory.fetch_by_player_id(requester.id)
      @partener_inventory = Inventory.fetch_by_player_id(params["partner_player_id"])

      ActiveRecord::Base.transaction do        
        params["requeser_items"].each do |item|
          self.partener_inventory.add(item["name"], item["count"])
          self.requester_inventory.take_out(item["name"], item["count"])
        end
        
        params["partner_items"].each do |item|
          self.requester_inventory.add(item["name"], item["count"])
          self.partener_inventory.take_out(item["name"], item["count"])
        end
      end                

      return {sucess: true}
  end

  private 
  attr_reader :requester_inventory,  :partener_inventory
  

end

