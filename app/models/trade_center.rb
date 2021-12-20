# frozen_string_literal: true

# TODO: 現在はinventoryから呼び出されているのでinventory内にテストを書いてある
class TradeCenter
  def fetch_survivor_inventories
    players = Player.only_survivor
    stocks = ItemStock.where(player: players)

    grouping_items_by_player(players, stocks).map do |player_id, ss|
      Inventory.new(player_id, ss)
    end
  end

  def fetch_not_survivor_inventories
    players = Player.where(status: [Player.statuses[:zombie], Player.statuses[:death]])
    stocks = ItemStock.where(player: players)

    grouping_items_by_player(players, stocks).map do |player_id, ss|
      Inventory.new(player_id, ss)
    end
  end

  private

  def grouping_items_by_player(players, stocks)
    grouped_stocks = {}
    players.map do |p|
      grouped_stocks[p.id] = []
    end

    stocks.each do |stock|
      grouped_stocks[stock.player_id].push(stock)
    end

    grouped_stocks
  end
end
