# frozen_string_literal: true

class DeleteUnusedColumns < ActiveRecord::Migration[6.1]
  def up
    remove_column :players, :counting_to_starvation
    remove_column :items, :effect_value
    remove_column :items, :kind
  end

  def down
    add_column :players, :counting_to_starvation, :integer, null: false, default: 0
    add_column :items, :effect_value, :integer, null: false, default: 0
    add_column :items, :kind, :integer, null: false, default: 0
  end
end
