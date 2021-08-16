# frozen_string_literal: true

RSpec.describe 'Filed', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }

  describe 'GET /' do
    it 'returns http success' do
      get '/filed', headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT /current_location' do
    subject { put '/filed/current_location', headers: headers }

    before do
      create(:player, :survivor, current_lat: 0, current_lon: 0)
    end

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:success)
    end

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

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:success)
    end
  end
end
