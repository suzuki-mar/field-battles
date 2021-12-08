# frozen_string_literal: true

class AddKindToItem < ActiveRecord::Migration[6.1]
  def up
    add_column :items, :kind, :integer, default: 0
    # すでに作成されているテーブルにNotNullなカラムを追加する場合は作成後にNotNullにしたほうがいい (RubocopのRails/NotNullColumnで指摘される)
    change_column_null :items, :kind, true
  end

  def down
    remove_column :items, :kind
  end
end
