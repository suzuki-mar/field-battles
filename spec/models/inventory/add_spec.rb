# frozen_string_literal: true

# inventory_specのinventoryの主要な責務であるアイテムの追加と取り出しのテストが肥大化したためテストが見づらくなってしまったので切り出した

RSpec.describe Inventory, type: :model do
  let(:player) { create(:player, :newcomer) }
  let!(:inventory) do
    described_class.register_for_newcomer!(player.id, [])
  end
  let(:item_name) { Item::Name::FIRST_AID_POUCH }
  let(:stock_count) { 3 }

  before do
    SetUpper.prepare_items
  end

  describe('正常系') do
    subject do
      inventory.add!(item_name, 1)
      inventory.reload
      inventory
    end

    context('存在しないアイテムを追加する場合') do
      it '在庫を新規登録していること' do
        subject
        item_stock = inventory.stocks.first
        expect(item_stock.item.name).to eq(item_name)
        expect(item_stock.stock_count).to eq(1)
      end
    end

    context('同じアイテムがすでに存在する場合') do
      before do
        item = Item.where(name: item_name).first
        create(:item_stock, player: player, item: item, stock_count: 1)
      end

      it '在庫のカウントが増えていること' do
        subject
        item_stock = inventory.stocks.first
        expect(item_stock.stock_count).to eq(2)
      end
    end
  end

  describe 'ロールバック' do
    subject do
      inventory.add!('Unknown Item', 3)
    end

    it '例外が発生していること' do
      expect do
        subject
      end.to raise_error(ActiveRecord::Rollback)
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
        ActiveRecord::Base.transaction do
          zombie_inventory.add!(item_name, 1)
        end

        error = zombie_inventory.errors.first
        error.messages.first
      end

      let(:zombie_inventory) do
        player = create(:player, :newcomer)
        inventory = described_class.register_for_newcomer!(player.id, [])
        player.update(status: Player.statuses[:zombie])
        
        inventory 
      end

      it 'エラーが返されていること' do
        i18n_key = 'error_message.inventory.inventory_control.executed_by_nonsurvivors'
        expect(subject).to eq(I18n.t(i18n_key))
      end
    end
  end
end
