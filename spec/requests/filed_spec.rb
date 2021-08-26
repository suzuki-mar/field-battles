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

    before do
      create(:player, :survivor, current_lat: 0, current_lon: 0)
    end

    it_behaves_like "returns http success"

    it 'ユースケースが実行されていること' do
      subject

      location = Player.first.current_location
      expect(location.lat).not_to eq(0)
      expect(location.lon).not_to eq(0)
    end
  end

  describe 'PUT /infectio' do
    subject { put '/filed/infection', headers: headers }

    before do
      create_list(:player, 30, :survivor)
    end

    it 'ユースケースが実行されていること' do
      subject

      expect(Player.exists?(status: Player.statuses[:zombie])).to eq(true)
    end

    it_behaves_like "returns http success"
  end
end
