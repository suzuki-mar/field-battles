# frozen_string_literal: true

class ItemCalculator
  def execute(filed)
    @filed = filed
    @trade_center = TradeCenter.new

    {
      average_count_per: calc_average_count_per_item,
      wasted_points: calc_of_wasted_points
    }
  end

  private

  attr_reader :filed, :trade_center

  def calc_average_count_per_item
    count_totals = count_totals_per_items
    survivor_count = filed.survivors.count

    count_totals.map do |name, c|
      count = if c.to_f.zero?
                0
              else
                (c.to_f / survivor_count).round
              end

      { name: name, count: count }
    end
  end

  def count_totals_per_items
    survivor_inventories = trade_center.fetch_survivor_inventories
    item_name_and_points = Item.fetch_all_name_and_point

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

  def calc_of_wasted_points
    not_survivor_inventories = trade_center.fetch_not_survivor_inventories

    # inventorごとに計算をするとN+1になってしまうため、一度IDをまとめる
    item_stock_ids = []
    not_survivor_inventories.each do |inventory|
      item_stock_ids += inventory.stocks.pluck(:id)
    end

    all_item_stocks = ItemStock.where(id: item_stock_ids).includes(:item)

    wasted_points = 0
    all_item_stocks.each do |stock|
      wasted_points += stock.calc_total_point
    end

    wasted_points
  end
end
