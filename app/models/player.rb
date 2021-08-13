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
class Player < ApplicationRecord
  has_many :item_stocks, dependent: :destroy

  COUNT_OF_BEFORE_BECOMING_ZOMBIE = 5
  enum statuses: { newcomer: 0, survivor: 1, zombie: 2, deaths: 3 }
end
