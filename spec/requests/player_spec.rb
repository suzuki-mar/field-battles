# frozen_string_literal: true

RSpec.describe 'Players', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before do
    SetUpper.prepare_items
  end

  describe 'POST /' do
    subject do
      post '/players', params: params, headers: headers
    end

    let(:params) do
      JsonParserSupport.file('spec/parameters/registe_newcomer.json', :not_symbolize)
    end

    before do
      SetUpper.prepare_filed
    end

    context 'パラメーターが正しい場合' do
      it '生存者が存在すること' do
        subject

        filed = Filed.new
        filed.load_survivors

        expect(filed.survivors.count).to eq(1)
      end

      it 'イベントリが作成されていること' do
        subject

        filed = Filed.new
        filed.load_survivors
        new_survivor = filed.survivors.first

        expect(ItemStock.exists?(player_id: new_survivor.id)).to eq(true)
      end

      it '戻り値が正しいこと' do
        subject
        json = JSON.parse(response.body, { symbolize_names: true })
        expect(json[:success]).to eq(true)
        expect(json[:player]).not_to be_nil
      end

      it_behaves_like 'returns http success'
    end

    context('パラメーターが不正な場合') do
      context('プレイヤーのパラメーターが不正な場合') do
        before do
          params['age'] = -1
        end

        it('エラーが返されること') do
          subject
          json = JSON.parse(response.body, { symbolize_names: true })
          expect(json[:success]).to eq(false)
        end

        it_behaves_like 'returns http bad request'
      end

      context('インベントリのパラメーターが不正な場合') do
        before do
          params['inventory'].first['count'] = -1
        end

        it('エラーが返されること') do
          subject
          json = JSON.parse(response.body, { symbolize_names: true })
          expect(json[:success]).to eq(false)
        end

        it('プレイヤーが作成されていないこと') do
          expect { subject }.not_to change(Player.all, :count)
        end

        it_behaves_like 'returns http bad request'
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
      JsonParserSupport.file('spec/parameters/exchange_items.json', :not_symbolize)
    end

    before do
      SetUpper.prepare_items
      create_requester_inventory(params)
      create_partner_inventory(params)
    end

    context('パラメーターが正しい場合') do
      it 'アイテムの交換ができていること' do
        subject
        item_stock = ItemStock.first
        expect(item_stock.stock_count).to eq(0)
      end

      it_behaves_like 'returns http success'
    end

    context('パラメーターが間違っている場合') do
      before do
        params['requeser_items'].first['count'] = 1
      end

      it 'エラーキーを返していること' do
        subject
        expect(JsonParserSupport.response_body(response)).to have_key(:error_keys)
      end

      it_behaves_like 'returns http bad request'
    end

    xcontext('idがが間違っている場合')

    def create_requester_inventory(params)
      inventory = Inventory.build_with_empty_item_stocks(player.id)

      params['requeser_items'].each do |p|
        inventory.add!(p['name'], p['count'])
      end
    end

    def create_partner_inventory(params)
      player = create(:player, :survivor, id: params['partner_player_id'])
      inventory = Inventory.build_with_empty_item_stocks(player.id)

      params['partner_items'].each do |p|
        inventory.add!(p['name'], p['count'])
      end
    end
  end
end
