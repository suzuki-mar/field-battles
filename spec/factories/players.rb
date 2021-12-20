# frozen_string_literal: true

# == Schema Information
#
# Table name: players
#
#  id                        :integer          not null, primary key
#  age                       :integer          not null
#  counting_to_become_zombie :integer          not null
#  current_lat               :float            not null
#  current_lon               :float            not null
#  name                      :string           not null
#  status                    :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
FactoryBot.define do
  factory :player do
    name { Faker::Name.unique.name }
    age { Faker::Number.between(from: 18, to: 65) }
    counting_to_become_zombie { Player::COUNT_OF_BEFORE_BECOMING_ZOMBIE }
    current_lat { Location.build_distance_to_travel.lat }
    current_lon { Location.build_distance_to_travel.lon }
    status { Player.statuses[:newcomer] }

    trait :noninfected do
      status { Player.statuses[:noninfected] }
    end

    trait :infected do
      status { Player.statuses[:infected] }
    end

    trait :survivor do
      status do
        status = %i[noninfected infected].sample
        Player.statuses[status]
      end
    end

    trait :zombie do
      status { Player.statuses[:zombie] }
      counting_to_become_zombie { 0 }
    end

    trait :death do
      status { Player.statuses[:death] }
    end

    trait :with_inventory do
      after(:create) do |player|
        inventory = Inventory.build_with_empty_item_stocks(player.id)
        item = create(:item)
        inventory.add!(item.name, 1)
      end
    end

    trait :infection_complete do
      status { Player.statuses[:infected] }
      counting_to_become_zombie { 0 }
    end
  end
end
