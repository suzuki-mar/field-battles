# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  point      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Item < ApplicationRecord
  has_one :item_stock, dependent: :destroy

  enum kinds: { first_aid_kit: 0, drink: 1, weapone: 2 }

  module Name
    FIJI_WATER = 'Fiji Water'
    CAMPBELL_SOUP = 'Campbell Soup'
    FIRST_AID_POUCH = 'First Aid Pouch'
    AK47 = 'AK47'
  end

  class << self
    def fetch_all_name_and_point
      all.map do |item|
        { name: item.name, point: item.point }
      end
    end

    def create_initial_items
      create(name: Name::FIJI_WATER, point: 14)
      create(name: Name::CAMPBELL_SOUP, point: 12)
      create(name: Name::FIRST_AID_POUCH, point: 10)
      create(name: Name::AK47, point: 8)
    end
  end
end
