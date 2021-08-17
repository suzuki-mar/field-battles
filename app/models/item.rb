# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id           :integer          not null, primary key
#  effect_value :integer          not null
#  kind         :integer          not null
#  name         :string           not null
#  point        :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
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
        {name: item.name, point: item.point}
      end
    end

    def create_initial_items
      create(name: Name::FIJI_WATER, effect_value: 3, point: 14, kind: Item.kinds[:drink])
      create(name: Name::CAMPBELL_SOUP, effect_value: 2, point: 12, kind: Item.kinds[:drink])
      create(name: Name::FIRST_AID_POUCH, effect_value: 1, point: 10, kind: Item.kinds[:first_aid_kit])
      create(name: Name::AK47, effect_value: 1, point: 8, kind: Item.kinds[:weapone])
    end
  end

  
end
