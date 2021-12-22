# frozen_string_literal: true

RSpec.describe TradeCenter, type: :model do
  let(:trade_center) { described_class.new }

  before do
    SetUpper.prepare_items
  end

  describe('fetch_all_survivor_inventories') do
    subject { trade_center.fetch_survivor_inventories }

    before do
      # create時はsurvivorである必要がある
      players = create_list(:player, 3, :survivor)

      stock_params = [
        { name: Item::Name::FIRST_AID_POUCH, count: 1 }
      ]
      players.each do |p|
        Inventory.register_for_newcomer!(p.id, stock_params)
      end

      first_player_inventory = Inventory.fetch_by_player_id(players.first.id)
      first_player_inventory.add!(Item::Name::AK47, 2)

      players.last.update_status!(:death)
    end

    it 'すべての生存者のインベントリを取得する' do
      expect(subject.count).to eq(2)
      expect(subject.first.stocks.count).to eq(2)
    end
  end

  describe('fetch_all_not_survivor_inventories') do
    subject { trade_center.fetch_not_survivor_inventories }

    before do
      players = create_list(:player, 4, :survivor)

      stock_params = [
        { name: Item::Name::FIRST_AID_POUCH, count: 1 }
      ]
      players.each do |p|
        Inventory.register_for_newcomer!(p.id, stock_params)
      end

      players[0].update_status!(:zombie)
      players[1].update_status!(:zombie)
      players[2].update_status!(:death)
    end

    it 'すべての非生存者のインベントリを取得する' do
      expect(subject.count).to eq(3)
    end
  end
end
