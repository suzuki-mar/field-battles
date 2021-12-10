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

RSpec.describe Item, type: :model do
  describe 'validations' do
    describe 'point' do
      it { is_expected.to validate_presence_of(:point) }
      it { is_expected.to allow_value(1).for(:point) }
      it { is_expected.not_to allow_value(0).for(:point) }
    end

    describe 'name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to allow_value(described_class::Name::FIRST_AID_POUCH).for(:name) }
      it { is_expected.not_to allow_value('Unknown item').for(:name) }
    end
  end

  describe 'i18nの確認' do  

    it 'モデル名の設定ができていること' do 
      expect(described_class.model_name.human).to eq("アイテム")
    end

    it "kindの設定ができていること" do 
      expect(described_class.human_attribute_name(:kind)).to eq("種類")
    end

    it "pointの設定ができていること" do 
      expect(described_class.human_attribute_name(:point)).to eq("ポイント")
    end

    it "nameの設定ができていること" do 
      expect(described_class.human_attribute_name(:name)).to eq("アイテム名")
    end

  end

  describe 'auto_assign_attributes_from_name' do
    subject do
      item.valid?
    end

    let(:item) { described_class.new(name: Item::Name::AK47) }

    it 'アイテム名から値を自動設定する' do
      subject
      expect(item.point).not_to be_nil
    end
  end

  describe 'create_initial_items' do
    subject { described_class.create_initial_items }

    it 'すべてのアイテムが作成されていること' do
      subject
      expect(described_class.all.count).to eq(described_class.build_all_names.count)
    end

    it '全ての値が設定されていること' do
      subject
      attributes = described_class.first.attributes
      attributes.delete('kinds')
      everything_has_value = attributes.all? { |_key, value| !value.nil? }
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
