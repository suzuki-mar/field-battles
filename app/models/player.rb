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

# 生存者、ゾンビなどがあるため一つのクラスにそれぞれの振る舞いを実装をするとコードが複雑になる
# 継承を使用すると異なるタイプ同士で予想していない振る舞い担ってしまう可能性もある
# そのため、ぞれぞれの状態にあわせてSurvivorなどのクラスを作成している
class Player < ApplicationRecord
  has_many :item_stocks, dependent: :destroy

  before_validation :assign_default_value_if_new_record
  validates :age, presence: true, numericality: { greater_than_or_equal_to: 18, less_than_or_equal_to: 65 }
  validates :counting_to_become_zombie, presence: true,
                                        numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :current_lat, presence: true,
                          numericality: {
                            greater_than_or_equal_to: Filed::LAT_RANGE.begin,
                            less_than_or_equal_to: Filed::LAT_RANGE.end
                          }

  validates :current_lon, presence: true,
                          numericality: {
                            greater_than_or_equal_to: Filed::LON_RANGE.begin,
                            less_than_or_equal_to: Filed::LON_RANGE.end
                          }

  COUNT_OF_BEFORE_BECOMING_ZOMBIE = 5
  enum status: { newcomer: 0, noninfected: 1, infected: 2, zombie: 3, death: 4 }

  scope :only_survivor, -> { where(status: [Player.statuses[:noninfected], Player.statuses[:infected]]) }

  def current_location
    Location.build_current_location(self)
  end

  def can_see?(compare)
    current_location.can_sight?(compare.current_location)
  end

  def self.survivor?(id)
    player = find(id)
    player.noninfected? || player.infected?
  end
  
  def update_status!(status)
    update!(status: Player.statuses[status])
  end

  def self.newcomer?(id)
    player = find(id)
    player.newcomer?
  end

  class << self
    def build_at_random_location(params)
      initial_location = Location.build_distance_to_travel
      new(
        name: params[:name], age: params[:age], current_lat: initial_location.lat, current_lon: initial_location.lon
      )
    end
  end

  private

  def assign_default_value_if_new_record
    return unless new_record?

    self.counting_to_become_zombie = COUNT_OF_BEFORE_BECOMING_ZOMBIE if counting_to_become_zombie.nil?
    self.status = Player.statuses[:newcomer] if status.nil?
  end
end
