# frozen_string_literal: true

RSpec.describe FiledContext::GenerateReportForCurrentSituation do
  describe 'execute' do
    subject do
      usecase = described_class.new
      usecase.execute
    end

    before do
      Item.create_initial_items

      # アイテムの所持数 
      # FIJI_WATER: 非感染者 2 感染者3
      # AK47 感染者 10
      # FIRST_AID_POUCH 非感染者 3

      6 * 2

      # 一人は感染する感染する生存者を発生させたいので多めに作成している
      create_list(:player, 6, :survivor)
      create_list(:player, 5, :infected)
      create_list(:player, 3, :zombie)
      create_list(:player, 2, :death)     

      noninfected_survivors = Player.where(status: Player.statuses[:survivor])
      noninfected_item_params = [
        {name: Item::Name::FIJI_WATER, count: 2},
        {name: Item::Name::FIRST_AID_POUCH, count: 3}
      ]
      
      noninfected_survivors.each do |s|
        inventory = Inventory.create_for_newcomers(s.id, noninfected_item_params)
      end
    end

    # 計算自体はサービスクラスに異常している
    it 'プレイ人口の割合が計算できていること' do
      expect(subject[:noninfected_percentage]).not_to be_nil
      expect(subject[:infected_percentage]).not_to be_nil
      expect(subject[:infected_percentage]).not_to be_nil
    end

    xit '戻り値が正しいこと' do
      expect(subject).to eq(true)
    end
  end

  xit '感染者か非感染者がいない場合'

end
