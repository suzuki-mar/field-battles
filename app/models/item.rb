# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id         :integer          not null, primary key
#  kind       :integer          default(0)
#  name       :string           not null
#  point      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Item < ApplicationRecord
  before_validation :assign_attributes_from_name_if_new_record
  validates :name,  presence: true, allow_blank: false
  validate :validate_of_name_existant
  validates :point, presence: true, numericality: { only_integer: true, greater_than: 0 }
  has_one :item_stock, dependent: :destroy

  enum kinds: { first_aid_kit: 0, drink: 1, weapone: 2 }

  module Name
    FIJI_WATER = 'Fiji Water'
    CAMPBELL_SOUP = 'Campbell Soup'
    FIRST_AID_POUCH = 'First Aid Pouch'
    AK47 = 'AK47'
  end

  class << self
    def build_all_names
      Name.constants.map do |c|
        Name.const_get(c)
      end
    end

    def fetch_all_name_and_point
      all.map do |item|
        { name: item.name, point: item.point }
      end
    end

    def create_initial_items
      names = build_all_names
      names.each do |name|
        attributes = build_attributes_form_name(name)
        attributes[:name] = name
        create!(attributes)
      end
    end
  end

  private

  def assign_attributes_from_name_if_new_record
    return unless new_record?
    return if name.blank?

    attributes = self.class.build_attributes_form_name(name)
    return if attributes.blank?

    self.attributes = attributes
  end

  def validate_of_name_existant
    return if name.blank?

    names = self.class.build_all_names

    return if names.include?(name)
    errors.add(:name, I18n.t("error_message.item.name.nonexistent_name", :name => name))
  end

  class << self
    def build_attributes_form_name(name)
      attributes_list = {
        Name::FIJI_WATER => { point: 14, kind: kinds[:drink] },
        Name::CAMPBELL_SOUP => { point: 12, kind: kinds[:drink] },
        Name::FIRST_AID_POUCH => { point: 10, kind: kinds[:first_aid_kit] },
        Name::AK47 => { point: 8, kind: kinds[:weapone] }
      }

      attributes_list[name]
    end
  end
end
