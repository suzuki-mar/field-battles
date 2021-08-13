# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id           :integer          not null, primary key
#  effect_value :integer          not null
#  name         :string           not null
#  point        :integer          not null
#  type         :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Item < ApplicationRecord
  has_one :item_stock

  enum types: { first_aid_kit: 0, drink: 1, weapone: 2}
end
