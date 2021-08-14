# frozen_string_literal: true

class ChangeTypeColumnNameOfItem < ActiveRecord::Migration[6.1]
  def change
    # typeはARの単一継承で使用するため使用できない名前
    rename_column :items, :type, :kind
  end
end
