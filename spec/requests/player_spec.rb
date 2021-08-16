# frozen_string_literal: true

RSpec.describe 'Players', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before do
    Item.create_initial_items
  end

  describe 'POST /' do
    subject do
      post '/players', params: params, headers: headers
    end

    let(:params) do
      ReadJsonFile.read('spec/parameters/registe_new_survivor.json', :not_symbolize)
    end

    context('パラメーターが正しい場合') do
      it '新しい生存者を作成していること' do
        subject

        player = Player.first
        expect(player.status).to eq(Player.statuses[:survivor])
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PUT /players/:player_id/inventory' do
    subject do
      put "/players/#{player.id}/inventory", params: params, headers: headers
    end

    let(:player) do
      create(:player, :survivor)
    end

    let(:params) do
      ReadJsonFile.read('spec/parameters/exchange_items.json', :not_symbolize)
    end

    before do
      Item.create_initial_items
      create_requester_inventory(params)
      create_partner_inventory(params)
    end

    context('パラメーターが正しい場合') do
      it 'アイテムの交換ができていること' do
        subject
        item_stock = ItemStock.first
        expect(item_stock.stock_count).to eq(0)
      end

      xit 'returns http success' do
        subject
        expect(response).to have_http_status(:success)
      end
    end

    xcontext('パラメーターが間違っている場合')
    xcontext('idがが間違っている場合')

    def create_requester_inventory(params)
      inventory = Inventory.fetch_by_player_id(player.id)

      params['requeser_items'].each do |p|
        inventory.add(p['name'], p['count'])
      end
    end

    def create_partner_inventory(params)
      player = create(:player, :survivor, id: params['partner_player_id'])
      inventory = Inventory.fetch_by_player_id(player.id)

      params['partner_items'].each do |p|
        inventory.add(p['name'], p['count'])
      end
    end
  end
end
