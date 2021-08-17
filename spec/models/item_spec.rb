# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id           :integer          not null, primary key
#  effect_value :integer          not null
#  kind         :integer          not null
#  name         :string           not null
#  point        :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

RSpec.describe Item, type: :model do
  describe('fetch_all_name_and_point') do
    subject { described_class.fetch_all_name_and_point }

    before do
      described_class.create_initial_items
    end

    it 'すべてのアイテム名とポイントを取得する' do
      expected = [
        { name: 'Fiji Water', point: 14 },
        { name: 'Campbell Soup', point: 12 },
        { name: 'First Aid Pouch', point: 10 },
        { name: 'AK47', point: 8 }
      ]

      expect(subject).to eq(expected)
    end
  end
end
