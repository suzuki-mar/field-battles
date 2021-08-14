# frozen_string_literal: true

RSpec.describe Inventory, type: :model do
  describe('fetch_by_player') do
    subject do
      described_class.fetch_by_player_id(player.id)
    end

    let(:player) { create(:player) }
    let(:item) { create(:item) }
    let!(:item_stock) { create(:item_stock, player: player, item: item) }

    it('playerのアイテムリストを取得する') do
      expect(subject.player_id).to eq(player.id)
      expect(subject.stocks.first.stock_count).to eq(item_stock.stock_count)
    end

    xit '存在しないidの場合に例外を発生させる'
  end

  describe('add') do
    subject { inventory.add(Item::Name::FIRST_AID_POUCH, 1) }

    let(:player) do
      create(:player)
    end

    let!(:inventory) do
      described_class.fetch_by_player_id(player.id)
    end

    context('存在しないアイテムを追加する場合') do
      before do
        Item.create_initial_items
      end

      it '在庫が追加していること' do
        subject
        inventory.reload
        item_stock = inventory.stocks.first
        expect(item_stock.item.name).to eq(Item::Name::FIRST_AID_POUCH)
        expect(item_stock.stock_count).to eq(1)
      end
    end

    context('同じアイテムがすでに存在する場合') do
      before do
        Item.create_initial_items
        item = Item.where(name: Item::Name::FIRST_AID_POUCH).first
        create(:item_stock, player: player, item: item, stock_count: 1)
      end

      it '在庫を追加すること' do
        subject
        inventory.reload
        item_stock = inventory.stocks.first
        expect(item_stock.stock_count).to eq(2)
      end
    end

    # これから実装したい仕様(時間があれば)
    xcontext('存在しないアイテム名のものを追加しようとした場合')
    xcontext('1より小さい数を追加しようちした場合')
  end

  describe('take_out') do
    subject { inventory.take_out(Item::Name::FIRST_AID_POUCH, 3) }

    let(:player) do
      create(:player)
    end

    let!(:inventory) do
      described_class.fetch_by_player_id(player.id)
    end

    before do
      Item.create_initial_items
      item = Item.where(name: Item::Name::FIRST_AID_POUCH).first
      create(:item_stock, player: player, item: item, stock_count: 4)
    end

    it '在庫からアイテムを取り出していること' do
      expect(subject[:count]).to eq(3)
      expect(subject[:name]).to eq(Item::Name::FIRST_AID_POUCH)
    end

    # これから実装したい仕様(時間があれば)
    xcontext('存在しないアイテム名のものを取り出そうとした場合')
    xcontext('存在する数以上のものを取得しようとした場合')
  end
end
