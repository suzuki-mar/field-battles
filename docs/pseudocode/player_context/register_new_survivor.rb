class PlayerContexts::RegisterNewSurvivor
  def execute(params)        
    
    start_transaction do 
      survivor = create_survivor_with_basic_information
      assign_initial_location_with_survivor
      register_initial_item_with_survivor
    end
    
    commit_transaction
  end

  private 
  attr_reader :survivor

  def create_survivor_with_basic_information
    player = Player.new()
    survivor = ...
  end

  def assign_initial_location
    survivor.assign_next_locations
  end

  def register_initial_item_with_survivor
    item_stocks = params.map do |param| 
      ItemStock.new(param)
    end

    Inventory.create_for_newcomers(survivor.id, item_stocks)
  end

end