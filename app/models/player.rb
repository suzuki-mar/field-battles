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

# 生存者、ゾンビなどがあるため一つのクラスにそれぞれの振る舞いを実装をするとコードが複雑になる
# 継承を使用すると異なるタイプ同士で予想していない振る舞い担ってしまう可能性もある
# そのため、ぞれぞれの状態にあわせてSurvivorなどのクラスを作成している
class Player < ApplicationRecord
  has_many :item_stocks, dependent: :destroy

  validates :age, presence: true, numericality: {greater_than: 17, less_than: 66}
  validates :counting_to_become_zombie, presence: true, numericality: {greater_than: -1, less_than: 6}
  validates :current_lat, presence: true, numericality: {greater_than_or_equal_to: Filed::LAT_RANGE.begin, less_than: Filed::LAT_RANGE.end + 1}
  validates :current_lon, presence: true, numericality: {greater_than_or_equal_to: Filed::LON_RANGE.begin, less_than: Filed::LON_RANGE.end + 1}

  COUNT_OF_BEFORE_BECOMING_ZOMBIE = 5
  # FIX survivorをnoninfectedに変更する
  enum statuses: { newcomer: 0, survivor: 1, infected: 2, zombie: 3, death: 4 }

  def current_location
    Location.build_current_location(self)
  end

  def can_see?(compare)
    current_location.can_sight?(compare.current_location)
  end
end
