# frozen_string_literal: true

# == Schema Information
#
# Table name: players
#
#  id                        :integer          not null, primary key
#  age                       :integer          not null
#  counting_to_become_zombie :integer          not null
#  counting_to_starvation    :integer          not null
#  current_lat               :float            not null
#  current_lon               :float            not null
#  name                      :string           not null
#  status                    :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
FactoryBot.define do
  factory :player do
    name { Faker::Name.unique.name}
    age { Faker::Number.between(from: 18, to: 65) }
    counting_to_become_zombie { Player::COUNT_OF_BEFORE_BECOMING_ZOMBIE }
    counting_to_starvation {3}
    current_lat {DummyData.lat}
    current_lon {DummyData.lon}
    status {Player.statuses[:newcomer]}

    trait :survivor do
      status {Player.statuses[:survivor]}
    end
  end
end