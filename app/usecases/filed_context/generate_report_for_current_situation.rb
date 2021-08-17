# APIは以下のレポートを提供する必要があります。

# 感染した生存者の割合。
# 感染していない生存者の割合
# 生存者による各種類のリソースの平均量（例：生存者1人あたり10フィジーウォーター
# 感染した生存者のために失われたポイント。

class FiledContext::GenerateReportForCurrentSituation

  def execute
    filed = Filed.new
    all_players = Player.all
    filed.load_survivors    
    calculator = PlayerStatusPercentageCalculator.new
    player_status_percentage = calculator.execute(all_players, filed)
    
    return {
      infected_percentage: player_status_percentage[:infected_percentage]
      infected_percentage_including_zombies: player_status_percentage[:infected_percentage_including_zombies],     
      noninfected_percentage: player_status_percentage[:noninfected_percentage],     ,     
      # average_amount_of_each_item_possessed: calc_average_amount_of_each_item_possessed
    }
    
    # {
    #   "zombie_percentage": calc_zombie_percentage,
    #   "survivor_percentage": calc_survivor_percentage,
    #   "average_amount_of_each_item_possessed": calc_average_amount_of_each_item_possessed
    #   "points_wasted": calc_points_wasted
    # }

  end

  private 
  attr_reader :all_item_name_and_points

  def calc_average_amount_of_each_item_possessed
    all_survivor_inventories = Inventory.fetch_all_survivor_inventories
      
    counts = {}
    all_item_name_and_points.map do |np|
      counts[np[:name]] = 0
    end

    all_survivor_inventories.each do |inventory|      
      inventory.all_stock_name_and_count.each do |stock_name_and_count|  
        key = stock_name_and_count[:name]
        counts[key] = counts[key] + stock_name_and_count[:count]
      end
    end

    counts
  end

  # def calc_points_wasted
  #   inventories = Inventory.fetch_all_not_surviving_players
    
  #   all_points = 0
  #   inventories.each do |inventory| 
  #     all_points = inventory.all_stocks_point
  #   end

  #   all_points
  # end

end