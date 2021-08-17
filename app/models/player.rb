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

  before_validation :assign_default_value_if_new_record

  COUNT_OF_BEFORE_BECOMING_ZOMBIE = 5
  # FIX survivorをnoninfectedに変更する
  enum statuses: { newcomer: 0, survivor: 1, infected: 2, zombie: 3, death: 4 }

  scope :only_survivor, -> { where(status: [Player.statuses[:survivor], Player.statuses[:infected]]) }

  def current_location
    Location.build_current_location(self)
  end

  def can_see?(compare)
    current_location.can_sight?(compare.current_location)
  end

  private

  def assign_default_value_if_new_record
    return unless new_record?

    self.counting_to_become_zombie = COUNT_OF_BEFORE_BECOMING_ZOMBIE if counting_to_become_zombie.nil?
    self.counting_to_starvation = 3 if counting_to_starvation.nil?
    self.status = Player.statuses[:newcomer] if status.nil?
  end
end
