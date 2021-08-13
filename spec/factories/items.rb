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
FactoryBot.define do
  factory :item do
    name {DummyData.item_name}
    effect_value {10}
    point {8}
    type {Item.types[:first_aid_kit]}    
  end
end
