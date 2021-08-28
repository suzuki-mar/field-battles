# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  point      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Item < ApplicationRecord
  before_validation :assign_attributes_from_name_if_new_record

  validates :point, presence: true, numericality: {greater_than_or_equal_to: 1}
  validates :name, presence: true
  validate :name, :validate_exists_in_name_list

  has_one :item_stock, dependent: :destroy

  enum kinds: { first_aid_kit: 0, drink: 1, weapone: 2 }

  module Name
    FIJI_WATER = 'Fiji Water'
    CAMPBELL_SOUP = 'Campbell Soup'
    FIRST_AID_POUCH = 'First Aid Pouch'
    AK47 = 'AK47'
  end

  class << self
    def fetch_all_name_and_point
      all.map do |item|
        { name: item.name, point: item.point }
      end
    end

    def create_initial_items
      create(name: Name::FIJI_WATER)
      create(name: Name::CAMPBELL_SOUP)
      create(name: Name::FIRST_AID_POUCH)
      create(name: Name::AK47)
    end
  end

  private
  def validate_exists_in_name_list
    keys = Item::Name.constants
    names = keys.map { |key| Item::Name.const_get(key) }
    return if names.include?(name)

    errors.add(:name, "#{name}は存在しない名前のアイテムです")
  end

  def assign_attributes_from_name_if_new_record
    return unless new_record?

    case name
    when Name::AK47
      self.point = 8
    when Name::FIJI_WATER
      self.point = 14
    when Name::CAMPBELL_SOUP
      self.point = 12
    when Name::FIRST_AID_POUCH
      self.point = 10
    end

    
  end
end
