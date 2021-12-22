# frozen_string_literal: true

RSpec.describe InventoryControl, type: :service do
  let!(:inventory) do
    player = create(:player, :newcomer)
    Inventory.register_for_newcomer!(player.id, [])
  end
  let(:item_name) { Item::Name::FIRST_AID_POUCH }
  let(:stock_count) { 3 }
  let(:inventory_control) { described_class.new }

  before do
    SetUpper.prepare_items
  end

  describe('正常系') do
    subject do
      inventory_control.add(inventory, item_name, stock_count)
    end

    context('存在しないアイテムを追加する場合') do
      it '在庫を新規登録していること' do
        subject

        item_stock = ItemStock.all.first
        expect(item_stock.stock_count).to eq(stock_count)
      end
    end

    context('同じアイテムがすでに存在する場合') do
      before do
        item = Item.where(name: item_name).first
        create(:item_stock, player_id: inventory.player_id, item: item, stock_count: 1)
      end

      it '在庫のカウントが増えていること' do
        subject

        item_stock = ItemStock.all.first
        expect(item_stock.stock_count).to eq(stock_count + 1)
      end
    end
  end

  describe('パラメーターの異常系') do
    subject do
      ActiveRecord::Base.transaction do
        inventory.add!(params[:item_name], params[:count])
      end

      error = inventory.errors.first
      error.messages.first
    end

    let(:params) do
      {
        item_name: item_name,
        count: 1
      }
    end

    context('存在しないアイテム名のものを追加しようとした場合') do
      before do
        params[:item_name] = 'Unknow Item'
      end

      it 'エラーが返されていること' do
        expect(subject).to eq(I18n.t('error_message.item.nonexistent_name', name: params[:item_name]))
      end
    end

    context('整数ではない数を追加しようとした場合') do
      before do
        params[:count] = -1
      end

      it 'エラーが返されていること' do
        # stock_countのバリデーションンを実行するため最小限のチェックでいい
        expect(subject.present?).to eq(true)
      end
    end
  end

  describe('プレイヤーのバリデーション') do
    context('生存者ではないものが実行しようとした場合') do
      subject do
        error = inventory_control.add(zombie_inventory, item_name, stock_count)
        error.messages.first
      end

      let(:zombie_inventory) do
        player = create(:player, :newcomer)
        inventory = Inventory.register_for_newcomer!(player.id, [])
        player.update_status!(:zombie)

        inventory
      end

      it 'エラーが返されていること' do
        i18n_key = 'error_message.inventory.inventory_control.executed_by_nonsurvivors'
        expect(subject).to eq(I18n.t(i18n_key))
      end
    end
  end
end
