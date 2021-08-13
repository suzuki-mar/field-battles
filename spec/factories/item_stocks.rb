# == Schema Information
#
# Table name: item_stocks
#
#  id          :integer          not null, primary key
#  stock_count :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  items_id    :integer
#  players_id  :integer
#
# Indexes
#
#  index_item_stocks_on_items_id    (items_id)
#  index_item_stocks_on_players_id  (players_id)
#
# Foreign Keys
#
#  items_id    (items_id => items.id)
#  players_id  (players_id => players.id)
#
FactoryBot.define do
  factory :item_stocks do
    
  end
end
