# frozen_string_literal: true

RSpec.describe Inventory, type: :model do
  let(:player) { create(:player, :survivor) }
  let(:item_name) { Item::Name::FIRST_AID_POUCH }

  before do
    SetUpper.prepare_items
  end

  # add take_outはテストが肥大化したためinventory内のディレクトリに切り出してある

  describe('validate_for_newcomer') do
    subject do
      described_class.validate_for_newcomer(player_id, stock_params)
    end

    let(:stock_params) { [{ name: item_name, count: 1 }] }

    context 'パラメーターがエラーではない場合' do
      let(:player_id) { create(:player, :newcomer).id }

      it '空配列が返ること' do
        expect(subject).to be_blank
      end
    end

    context 'パラメーターがエラーの場合' do
      let(:player_id) do
        create(:player, :zombie).id
      end

      it 'エラーメッセージが存在すること' do
        message = subject.first.messages.first
        expect(message).to include('新規登録者以外に')
      end
    end
  end

  describe('fetch_by_player') do
    subject do
      described_class.fetch_by_player_id(player_id)
    end

    let(:item) { create(:item) }
    let!(:item_stock) { create(:item_stock, player: player, item: item) }

    context 'インベントリをもっているプレイヤーの場合' do 
      let(:player_id){player.id}
      it('playerのアイテムリストを取得する') do
        expect(subject.player_id).to eq(player.id)
        expect(subject.stocks.first.stock_count).to eq(item_stock.stock_count)
      end
    end
    
    context '存在しないプレイヤーの場合' do 
      let(:player_id){99999999999999}
      it('例外が発生する') do
        expect do
          subject
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

  end

  describe('register_for_newcomer!') do
    subject do
      stock_params = [{ name: item_name, count: 1 }]
      described_class.register_for_newcomer!(player_id, stock_params)
    end

    context 'パラメータが正しい場合' do
      let(:player_id) { player.id }

      it 'イベントリが作成されていること' do
        subject
        inventory = described_class.fetch_by_player_id(player.id)
        stock = inventory.stocks.first

        expect(stock.name).to eq(item_name)
        expect(stock.stock_count).to eq(1)
      end
    end

    context 'パラメータが正しくない場合' do
      let(:player_id) do
        create(:player, :zombie).id
      end

      it '例外が発生すること' do
        expect { subject }.to raise_error(ActiveRecord::Rollback)
      end
    end
  end

  describe('all_stock_name_and_count') do
    subject { inventory.all_stock_name_and_count }

    let(:stock_params) do
      [
        { name: Item::Name::FIJI_WATER, count: 2 },
        { name: Item::Name::AK47, count: 1 }

      ]
    end

    let!(:inventory) do
      player = create(:player, :survivor)
      described_class.register_for_newcomer!(player.id, stock_params)
    end

    it 'イベントリにあるすべての在庫情報を取得する' do
      expect(subject).to eq(stock_params)
    end
  end

  describe('stock_count_by_name') do
    subject { inventory.stock_count_by_name(target_name) }

    let(:item_name) { Item::Name::FIJI_WATER }

    let(:stock_param) do
      { name: item_name, count: 2 }
    end

    let!(:inventory) do
      player = create(:player, :survivor)
      described_class.register_for_newcomer!(player.id, [stock_param])
    end

    context 'アイテムが存在する場合' do
      let(:target_name) { item_name }

      it 'イベントリにあるすべての在庫情報を取得する' do
        expect(subject).to eq(stock_param[:count])
      end
    end

    context 'アイテムが存在しない場合' do
      let(:target_name) { 'unknown_name' }

      it 'イベントリにあるすべての在庫情報を取得する' do
        expect(subject).to eq(0)
      end
    end
  end

  # TODO: TradeCenterのテスト内に記述する
  describe('fetch_all_survivor_inventories') do
    subject { described_class.fetch_all_survivor_inventories }

    before do
      # create時はsurvivorである必要がある
      players = create_list(:player, 3, :survivor)

      stock_params = [
        { name: item_name, count: 1 }
      ]
      players.each do |p|
        described_class.register_for_newcomer!(p.id, stock_params)
      end

      first_player_inventory = described_class.fetch_by_player_id(players.first.id)
      first_player_inventory.add!(Item::Name::AK47, 2)

      players.last.update(status: Player.statuses[:death])
    end

    it 'すべての生存者のインベントリを取得する' do
      expect(subject.count).to eq(2)
      expect(subject.first.stocks.count).to eq(2)
    end
  end

  describe('fetch_all_not_survivor_inventories') do
    subject { described_class.fetch_all_not_survivor_inventories }

    before do
      # create時はsurvivorである必要がある
      players = create_list(:player, 4, :survivor)
      # players.push(create(:player, :death))
      # players.push(create(:player, :survivor))

      stock_params = [
        { name: item_name, count: 1 }
      ]
      players.each do |p|
        described_class.register_for_newcomer!(p.id, stock_params)
      end

      players[0].update(status: Player.statuses[:zombie])
      players[1].update(status: Player.statuses[:zombie])
      players[2].update(status: Player.statuses[:death])
    end

    it 'すべての非生存者のインベントリを取得する' do
      expect(subject.count).to eq(3)
    end
  end
end
