# frozen_string_literal: true

RSpec.describe FiledContext::GenerateReportForCurrentSituation do
  describe 'execute' do
    subject do
      usecase = described_class.new
      usecase.execute
    end

    before do
      Item.create_initial_items

      create_list(:player, 6, :survivor)
      create_list(:player, 3, :zombie)

      item_params = [
        { name: Item::Name::FIJI_WATER, count: 2 },
        { name: Item::Name::FIRST_AID_POUCH, count: 3 }
      ]

      Inventory.create_for_newcomers(Player.first.id, item_params)
      Inventory.create_for_newcomers(Player.last.id, item_params)
    end

    # 計算自体はサービスクラスに異常している
    it 'プレイ人口の割合が計算できていること' do
      expect(subject[:noninfected_percentage]).not_to be_nil
      expect(subject[:infected_percentage]).not_to be_nil
      expect(subject[:infected_percentage]).not_to be_nil
    end

    it 'アイテムの計算ができていること' do
      expect(subject[:average_count_per_items]).not_to be_nil
      expect(subject[:wasted_item_points]).not_to be_nil
    end
  end
end
