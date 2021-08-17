class DeleteUnusedColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :players, :counting_to_starvation
    remove_column :items, :effect_value
    remove_column :items, :kind
  end
end
