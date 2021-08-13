# frozen_string_literal: true

# == Schema Information
#
# Table name: item_stocks
#
#  id          :integer          not null, primary key
#  stock_count :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  item_id     :integer
#  player_id   :integer
#
# Indexes
#
#  index_item_stocks_on_item_id    (item_id)
#  index_item_stocks_on_player_id  (player_id)
#
# Foreign Keys
#
#  item_id    (item_id => items.id)
#  player_id  (player_id => players.id)
#
FactoryBot.define do
  factory :item_stock do
    stock_count {Faker::Number.between(from: 1, to: 10)}    
    association :player, factory: :player 
    association :item, factory: :item
  end
end
