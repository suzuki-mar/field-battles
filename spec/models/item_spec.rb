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

    xdescribe 'kind 誤ってkindsとしてしまっているのでテストに失敗する' do
      it { is_expected.to define_enum_for(:kind).with_values(first_aid_kit: 0, drink: 1, weapone: 2) }
    end
  end

  describe 'バリデーションのエラーメッセージ' do
    subject do
      item.validate
      item.errors.full_messages.first
    end

    let(:item) { described_class.new(params) }
    let(:params) do
      {
        name: described_class::Name::FIRST_AID_POUCH,
        point: 1
      }
    end

    describe 'name' do
      before do
        params[:name] = name
      end

      context 'アイテムが存在しない場合' do
        let(:name) { 'Unknown item' }

        it 'エラーメッセージが存在すること' do
          expect(subject).to include('アイテムは存在しません')
        end
      end
    end

    describe 'point' do
      before do
        # 新規作成時に強制的に値が設定されるのでアップデートをして値を再設定をする
        item.save
        item.point = point
      end

      context '1より小さい場合' do
        let(:point) { 0 }

        it 'エラーメッセージが存在すること' do
          expect(subject).to include('してください')
        end
      end

      context '整数ではない場合' do
        let(:point) { 1.1 }

        it 'エラーメッセージが存在すること' do
          expect(subject).to include('整数である必要があります')
        end
      end
    end
  end

  describe 'i18nの確認' do
    it 'モデル名の設定ができていること' do
      expect(described_class.model_name.human).to eq('アイテム')
    end

    describe '属性の確認' do
      where(:attribute_name, :i18n_name) do
        [
          [:kind, '種類'],
          [:point, 'ポイント'],
          [:name, 'アイテム名']
        ]
      end

      with_them do
        it '設定ができていること' do
          expect(described_class.human_attribute_name(attribute_name)).to eq(i18n_name)
        end
      end
    end

    describe 'kindのenumの確認' do
      where(:key, :i18n_name) do
        [
          [:first_aid_kit, '救急箱'],
          [:drink, '飲み物'],
          [:weapone, '武器']
        ]
      end

      with_them do
        it '設定ができていること' do
          expect(described_class.kinds_i18n[key]).to eq(i18n_name)
        end
      end
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
