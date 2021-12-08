class AddKindToItem < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :kind, :integer, null: false
  end
end
