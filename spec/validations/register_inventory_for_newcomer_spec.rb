# frozen_string_literal: true

RSpec.describe RegisterInventoryForNewcomer, type: :validation do
  let(:player) { create(:player, :survivor) }
  let(:item_name) { Item::Name::FIRST_AID_POUCH }

  before do
    SetUpper.prepare_items
  end

  describe('validate_for_newcomer') do
    subject do
      described_class.new.validate(player_id, stock_params)
    end

    let(:player_id) { create(:player, :newcomer).id }
    let(:stock_params) { [{ name: item_name, count: 1 }] }

    context 'パラメーターがエラーではない場合' do
      it '空配列が返ること' do
        expect(subject).to be_blank
      end
    end

    context 'パラメーターがエラーの場合' do
      context 'プレイヤーが新規登録者ではない場合' do
        let(:player_id) do
          create(:player, :zombie).id
        end

        it 'エラーメッセージが存在すること' do
          message = subject.first.messages.first
          expect(message).to include('新規登録者以外に')
        end
      end

      context 'プレイヤーIDがnilの場合' do
        let(:player_id) do
          nil
        end

        it 'エラーメッセージが存在すること' do
          message = subject.first.messages.first
          expect(message).to include('新規登録者以外に')
        end
      end

      context 'アイテム名が不正な場合' do
        let(:stock_params)  do
          [
            { name: 'Unknown name 1', count: 1 },
            { name: 'Unknown name 2', count: 1 }
          ]
        end

        it 'エラーメッセージが存在すること' do
          all_error = subject.all? do |error|
            message = error.messages.first
            message.include?('アイテムは存在しません')
          end

          expect(all_error).to eq(true)
        end
      end

      context '在庫数が不正な場合' do
        let(:stock_params) do
          [
            { name: item_name, count: 0.1 }
          ]
        end

        it 'エラーメッセージが存在すること' do
          message = subject.first.messages.first
          expect(message).to include('在庫数は0以上')
        end
      end
    end
  end
end
