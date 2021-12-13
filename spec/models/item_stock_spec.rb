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

RSpec.describe ItemStock, type: :model do
  describe 'validations' do
    describe 'stock_count' do
      it { is_expected.to validate_presence_of(:stock_count) }
      it { is_expected.to allow_value(0).for(:stock_count) }
      it { is_expected.not_to allow_value(-1).for(:stock_count) }
    end

    describe 'item_id' do
      it { is_expected.to validate_presence_of(:item_id) }
    end

    describe 'player_id' do
      it { is_expected.to validate_presence_of(:player_id) }
    end
  end

  describe 'i18nの確認' do  

    it 'モデル名の設定ができていること' do 
      expect(described_class.model_name.human).to eq("在庫")
    end

    it "stock_countの設定ができていること" do 
      expect(described_class.human_attribute_name(:stock_count)).to eq("在庫数")
    end

  end

  describe 'バリデーションのエラーメッセージ' do
    let(:stock){described_class.new(params)}
    let(:params){
      {
        player: create(:player),
        stock_count: 1,
        item: create(:item)
      }
    }

    subject do 
      stock.validate          
      stock.errors.full_messages.first
    end

    where(:error_name, :compare_message, :attribute_name, :value) do
      [ 
        ["ストックが0の場合", "以上の値を設定してください", :stock_count, -1],                    
        ["プレイヤーが設定されていない場合", "プレイヤーが設定されていません", :player, nil],
        ["アイテムが設定されていない場合", "アイテムが設定されていません", :item, nil],        
      ]
    end

    before do 
      params[attribute_name] = value
    end
  
    with_them do        
      it "エラーメッセージが存在すること" do           
        expect(subject).to include(compare_message)
      end
    end    
  end
end
