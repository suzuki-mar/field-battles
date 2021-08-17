class ItemCalculator

  def execute(filed)
    @item_name_and_points = Item.fetch_all_name_and_point
    @filed = filed
    
    {
      average_count_per_item: calc_average_count_per_item
    }
    
  end

  private
  attr_reader :item_name_and_points, :filed
  def calc_average_count_per_item
    count_totals = count_totals_per_items
    survivor_count = filed.survivors.count

    count_totals.map do |name, c|
      count = (c.to_f / survivor_count).round
      {name: name, count: count}      
    end
  end


  def count_totals_per_items
    survivor_inventories = Inventory.fetch_all_survivor_inventories
      
    counts = {}
    item_name_and_points.map do |np|
      counts[np[:name]] = 0
    end

    survivor_inventories.each do |inventory|      
      inventory.all_stock_name_and_count.each do |stock_name_and_count|  
        key = stock_name_and_count[:name]
        counts[key] = counts[key] + stock_name_and_count[:count]
      end
    end

    counts
  end

end