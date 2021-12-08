# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id         :integer          not null, primary key
#  kind       :integer          not null
#  name       :string           not null
#  point      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

RSpec.describe Item, type: :model do
  describe 'validations' do
    describe 'point' do
      it { should validate_presence_of(:point) }
      it { should allow_value(1).for(:point) }
      it { should_not allow_value(0).for(:point) }
    end

    describe 'name' do
      it { should validate_presence_of(:name) }
      it { should allow_value(described_class::Name::FIRST_AID_POUCH).for(:name) }
      it {should_not allow_value("Unknown item").for(:name)}
    end
  end

  describe 'auto_assign_attributes_from_name' do

    let(:item){Item.new(name: Item::Name::AK47)}

    subject do
      item.valid?
    end

    it 'アイテム名から値を自動設定する' do 
      subject
      expect(item.point).not_to be_nil
    end

  end

  describe 'create_initial_items' do
    subject { described_class.create_initial_items }

    it 'すべてのアイテムが作成されていること' do 
      subject
      expect(Item.all.count).to eq(Item.build_all_names.count)
    end

    it '全ての値が設定されていること' do 
      subject
      attributes = Item.first.attributes
      attributes.delete("kinds")
      everything_has_value = attributes.all?{|key, value| !value.nil?}
      expect(everything_has_value).to eq(true)
    end

  end

  describe 'fetch_all_name_and_point' do
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

      expect(subject).to match_array(expected)
    end
  end
end
