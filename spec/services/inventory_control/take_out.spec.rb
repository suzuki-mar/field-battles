# frozen_string_literal: true

RSpec.describe InventoryControl, type: :service do
  let!(:inventory) do
    player = create(:player, :newcomer)
    Inventory.register_for_newcomer!(player.id, [])
  end
  let(:player) { create(:player, :newcomer) }
  let(:inventory_control){described_class.new}
  let(:item_name) { Item::Name::FIRST_AID_POUCH }
  let(:stock_count) { 3 }
  
  before do
    SetUpper.prepare_items
  end

  describe('正常系') do
    subject { inventory_control.take_out(inventory, item_name, stock_count) }

    before do
      item = Item.where(name: item_name).first
      create(:item_stock, player: player, item: item, stock_count: stock_count)
    end

    it '在庫からアイテムを取り出していること' do
      subject
      
      item_stock = ItemStock.all.first
      expect(item_stock.stock_count).to eq(stock_count)
      expect(item_stock.name).to eq(item_name)
    end
  end

  describe('stock_parassが異常') do
    subject do      
      error = inventory_control.take_out(inventory, params[:item_name], params[:count])
      error.messages.first
    end

    let(:params) do
      {
        item_name: item_name,
        count: 1
      }
    end

    context('登録されていないアイテムを取り出そうとした場合') do
      before do
        params[:item_name] = 'Unknow Item'
      end

      it 'エラーが返されていること' do
        i18n_key = 'error_message.inventory.take_out.unregistered_item'
        is_expected.to eq(I18n.t(i18n_key, name: params[:item_name]))
      end
    end

    context('存在数以上のものを取得しようとした場合') do
      before do
        params[:count] = stock_count + 1

        item = Item.where(name: item_name).first
        create(:item_stock, player_id: inventory.player_id, item: item, stock_count: stock_count)
      end

      it 'エラーが返されていること' do
        i18n_key = 'error_message.inventory.take_out.many_more_than_registered_quantity'
        is_expected.to eq(I18n.t(i18n_key, count: 3))
      end
    end
  end

  describe('プレイヤーIDが不正') do
    context('生存者ではないものが実行しようとした場合') do
      subject do
        zombie_inventory = Inventory.fetch_by_player_id(zombie.id)
        error = inventory_control.take_out(zombie_inventory, item_name, 1)
        error.messages.first
      end

      let(:zombie) do
        create(:player, :zombie)
      end

      before do
        item = Item.where(name: item_name).first
        create(:item_stock, player: zombie, item: item, stock_count: stock_count)
      end

      it 'エラーが返されていること' do
        i18n_key = 'error_message.inventory.inventory_control.executed_by_nonsurvivors'
        expect(subject).to eq(I18n.t(i18n_key))
      end
    end
  end
end
