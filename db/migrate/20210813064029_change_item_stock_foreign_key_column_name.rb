# frozen_string_literal: true

class ChangeItemStockForeignKeyColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :item_stocks, :items_id, :item_id
    rename_column :item_stocks, :players_id, :player_id
  end
end
