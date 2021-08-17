# frozen_string_literal: true

RSpec.describe Inventory, type: :model do
  let(:player) { create(:player) }
  let(:item_name) { Item::Name::FIRST_AID_POUCH }

  before do
    Item.create_initial_items
  end

  describe('fetch_by_player') do
    subject do
      described_class.fetch_by_player_id(player.id)
    end

    let(:item) { create(:item) }
    let!(:item_stock) { create(:item_stock, player: player, item: item) }

    it('playerのアイテムリストを取得する') do
      expect(subject.player_id).to eq(player.id)
      expect(subject.stocks.first.stock_count).to eq(item_stock.stock_count)
    end

    xit '存在しないidの場合に例外を発生させる'
  end

  describe('create_for_newcomers') do
    subject do
      stock_params = [{ name: item_name, count: 1 }]
      described_class.create_for_newcomers(player.id, stock_params)
    end

    it 'イベントリが作成されていること' do
      subject
      inventory = described_class.fetch_by_player_id(player.id)
      stock = inventory.stocks.first

      expect(stock.name).to eq(item_name)
      expect(stock.stock_count).to eq(1)
    end
  end

  describe('add') do
    subject { inventory.add(item_name, 1) }

    let!(:inventory) do
      described_class.fetch_by_player_id(player.id)
    end

    context('存在しないアイテムを追加する場合') do
      

      it '在庫が追加していること' do
        subject
        inventory.reload
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
    subject { inventory.take_out(item_name, 3) }

    let!(:inventory) do
      described_class.fetch_by_player_id(player.id)
    end

    before do      
      item = Item.where(name: item_name).first
      create(:item_stock, player: player, item: item, stock_count: 4)
    end

    it '在庫からアイテムを取り出していること' do
      expect(subject[:count]).to eq(3)
      expect(subject[:name]).to eq(item_name)
    end

    # これから実装したい仕様(時間があれば)
    xcontext('存在しないアイテム名のものを取り出そうとした場合')
    xcontext('存在する数以上のものを取得しようとした場合')
  end

  describe('all_stock_name_and_count') do
    let(:stock_params) do 
      [
        { name: Item::Name::FIJI_WATER, count: 2 },        
        { name: Item::Name::AK47, count: 1 },        

      ]      
    end
    
    let!(:inventory) do 
      player = create(:player, :survivor)
      described_class.create_for_newcomers(player.id, stock_params)
    end

    subject { inventory.all_stock_name_and_count } 

    it 'イベントリにあるすべての在庫情報を取得する' do       
      is_expected.to eq(stock_params)
    end
  end  

  describe('stock_count_by_name') do
    let(:item_name){Item::Name::FIJI_WATER}

    let(:stock_param) do 
      { name: item_name, count: 2 }
    end
    
    let!(:inventory) do 
      player = create(:player, :survivor)
      described_class.create_for_newcomers(player.id, [stock_param])
    end

    subject { inventory.stock_count_by_name(target_name) } 

    context 'アイテムが存在する場合' do 
      let(:target_name){item_name}

      it 'イベントリにあるすべての在庫情報を取得する' do       
        is_expected.to eq(stock_param[:count])
      end
    end

    context 'アイテムが存在しない場合' do 
      let(:target_name){"unknown_name"}

      it 'イベントリにあるすべての在庫情報を取得する' do       
        is_expected.to eq(0)
      end
    end

    
  end  

  describe('fetch_all_survivor_inventories') do
    
    before do       
      players = create_list(:player, 2, :survivor)
      players.push(create(:player, :zombie))

      stock_params = [
        { name: item_name, count: 1 },        
      ]
      players.each do |p|        
        described_class.create_for_newcomers(p.id, stock_params)
      end

      first_player_inventory = Inventory.fetch_by_player_id(players.first.id)      
      first_player_inventory.add(Item::Name::AK47, 2)
    end

    subject { described_class.fetch_all_survivor_inventories } 

    it 'すべての生存者のインベントリを取得する' do       
      expect(subject.count).to eq(2)
      expect(subject.first.stocks.count).to eq(2)
    end
  end  

  describe('fetch_all_not_survivor_inventories') do
    
    before do       
      players = create_list(:player, 2, :zombie)
      players.push(create(:player, :death))
      players.push(create(:player, :survivor))

      stock_params = [
        { name: item_name, count: 1 },        
      ]
      players.each do |p|        
        described_class.create_for_newcomers(p.id, stock_params)
      end
    end

    subject { described_class.fetch_all_not_survivor_inventories } 

    it 'すべての非生存者のインベントリを取得する' do       
      expect(subject.count).to eq(3)
    end
  end  
end
