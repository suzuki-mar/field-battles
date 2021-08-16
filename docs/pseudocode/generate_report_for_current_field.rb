# APIは以下のレポートを提供する必要があります。

# 感染した生存者の割合。
# 感染していない生存者の割合
# 生存者による各種類のリソースの平均量（例：生存者1人あたり10フィジーウォーター
# 感染した生存者のために失われたポイント。

class FiledContext::GenerateReportForCurrentSituation

  def execute
    @filed = Filed.new
    total_players_count = countting_total_players_count
    
    {
      "zombie_percentage": calc_zombie_percentage,
      "survivor_percentage": calc_survivor_percentage,
      "average_amount_of_each_item_possessed": calc_average_amount_of_each_item_possessed
      "points_wasted": calc_points_wasted
    }

  end

  private 
  :attr_reader :total_number_of_players, :filed, :total_players_count

  def countting_total_players_count
    Player.where....

  end

  def calc_zombie_percentage
    count = filed.fetch_zombies.count
    total_number_of_players / zombie_count
  end

  def calc_survivor_percentage
    count = filed.fetch_survivors.count
    total_number_of_players / count
  end

  def calc_average_amount_of_each_item_possessed
    all_survivor_inventories = Inventory.fetch_all_survivor_inventories
    all_item_names = Item.fetch_all_names

    count_list = all_item_names.map {|name| {name: name, count: 0}}

    count_list.each do |item|
      
      all_survivor_inventories.each do |inventorie|
        item[:count] += inventorie.count_by_name(item[:name])      
      end

    end

    count_list.map do |item|
      percentage = item[:count] / filed.fetch_survivors.count
      {name: item[:name], percentage: percentage}
    end

  end

  def calc_points_wasted
    inventories = Inventory.fetch_all_not_surviving_players
    
    all_points = 0
    inventories.each do |inventory| 
      all_points = inventory.all_stocks_point
    end

    all_points
  end

end