# frozen_string_literal: true

class CreateEachTables < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.integer :age, null: false
      t.integer :status, null: false
      t.integer :counting_to_starvation, null: false
      t.integer :counting_to_become_zombie, null: false
      t.float :current_lon, null: false
      t.float :current_lat, null: false

      t.timestamps
    end

    create_table :items do |t|
      t.string :name, null: false
      t.integer :type, null: false
      t.integer :effect_value, null: false
      t.integer :point, null: false

      t.timestamps
    end
    add_index :contents, [:name], unique: true

    create_table :item_stocks do |t|
      t.integer :stock_count, null: false
      t.references :items, foreign_key: true
      t.references :players, foreign_key: true
      t.timestamps
    end
  end
end
