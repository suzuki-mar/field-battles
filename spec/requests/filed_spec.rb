# frozen_string_literal: true

RSpec.describe 'Filed', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }

  describe 'GET /' do
    subject { get '/filed', headers: headers }

    before do
      SetUpper.prepare_filed

      create(:player, :survivor)
      create(:player, :zombie)

      item_params = [
        { name: Item::Name::FIJI_WATER, count: 2 },
        { name: Item::Name::FIRST_AID_POUCH, count: 3 }
      ]

      Inventory.create_for_newcomers(Player.first.id, item_params)
      Inventory.create_for_newcomers(Player.last.id, item_params)
    end

    it 'レポートの計算ができていること' do
      subject
      
      expect(JsonParserSupport.response_body(response)).to have_key(:infected_percentage)
    end

    it_behaves_like "returns http success"
  end

  describe 'PUT /current_location' do
    subject { put '/filed/current_location', headers: headers }

    let(:survivor_player) { create(:player, :survivor) }

    before do
      zombie_player = create(:player, :zombie)
      survivor_player.update(current_lat: zombie_player.current_lat, current_lon: zombie_player.current_lon)
      
      # 乱数での判定なためモックを使用している
      # TODO: 意味を理解するまで時間がかかるのでヘルパーにしたい
      allow_any_instance_of(Location).to receive(:can_sight?).and_return(true)
    end

    it '移動していること' do
      before_location = survivor_player.current_location
      subject
      after_location = survivor_player.reload.current_location

      expect(after_location.equal(before_location)).to eq(false)
    end

    it 'ゾンビに襲われていること' do
      subject
      expect(Player.find(survivor_player.id).status).to eq(Player.statuses[:death])
    end

    it_behaves_like "returns http success"

  end

  describe 'PUT /infectio' do
    subject { put '/filed/infection', headers: headers }

    before do
      # 一人は感染する感染する生存者を発生させたいので多めに作成している
      create_list(:player, 20, :survivor)
    end

    it 'ゾンビになった生存者がいること' do
      subject

      expect(Player.exists?(status: Player.statuses[:zombie])).to eq(true)
    end

    it_behaves_like "returns http success"
  end
end
