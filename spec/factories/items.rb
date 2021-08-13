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
  factory :items do
    
  end
end
