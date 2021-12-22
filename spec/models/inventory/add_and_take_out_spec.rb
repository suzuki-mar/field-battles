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

  describe 'add!' do
    context('正常系') do
      subject do
        inventory.add!(item_name, 1)
        inventory.reload
        inventory
      end

      it '在庫を登録していること' do
        subject
        item_stock = inventory.stocks.first
        expect(item_stock.stock_count).to eq(1)
      end
    end

    describe('異常系') do
      describe 'ロールバックの確認' do
        subject do
          inventory.add!('Unknown Item', 3)
        end

        it '例外が発生していること' do
          expect do
            subject
          end.to raise_error(ActiveRecord::Rollback)
        end
      end

      describe 'エラーメッセージの確認' do
        subject do
          ActiveRecord::Base.transaction do
            inventory.add!('Unknown item', stock_count)
          end

          error = inventory.errors.first
          error.messages.first
        end

        it 'エラーが返されていること' do
          expect(subject).to eq(I18n.t('error_message.item.nonexistent_name', name: 'Unknown item'))
        end
      end
    end
  end

  describe 'take_out' do
    describe('正常系') do
      subject { inventory.take_out!(item_name, stock_count) }

      before do
        item = Item.where(name: item_name).first
        create(:item_stock, player: player, item: item, stock_count: stock_count)
      end

      it '在庫からアイテムを取り出していること' do
        expect(subject.stock_count).to eq(0)
        expect(subject.name).to eq(item_name)
      end
    end

    describe 'ロールバック' do
      subject do
        inventory.take_out!(item_name, 3)
      end

      it '例外が発生していること' do
        expect do
          subject
        end.to raise_error(ActiveRecord::Rollback)
      end
    end
  end
end
