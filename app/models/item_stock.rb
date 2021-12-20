# frozen_string_literal: true

# == Schema Information
#
# Table name: item_stocks
#
#  id          :integer          not null, primary key
#  stock_count :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  item_id     :integer
#  player_id   :integer
#
# Indexes
#
#  index_item_stocks_on_item_id    (item_id)
#  index_item_stocks_on_player_id  (player_id)
#
# Foreign Keys
#
#  item_id    (item_id => items.id)
#  player_id  (player_id => players.id)
#
class ItemStock < ApplicationRecord
  delegate :name, to: :item

  belongs_to :item
  belongs_to :player

  validates :stock_count, presence: true
  validates :item_id, presence: true
  validates :player_id, presence: true
  validate :validate_of_stock_count_number

  def add_stock!(count)
    update!(stock_count: stock_count + count)
  end

  def reduce_stock!(count)
    update!(stock_count: stock_count - count)
  end

  def calc_total_point
    item.point * stock_count
  end

  class << self
    def valid_stock_count?(count)
      pattern = '^[0-9]+$'
      if /#{pattern}/.match(count.to_s)
        true
      else
        false
      end
    end
  end

  private

  def validate_of_stock_count_number
    return if stock_count.blank?
    return if self.class.valid_stock_count?(stock_count)

    errors.add(:stock_count, I18n.t('error_message.item_stock.stock_count'))
  end
end
