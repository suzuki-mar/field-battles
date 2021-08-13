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
require 'rails_helper'

RSpec.describe ItemStock, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
