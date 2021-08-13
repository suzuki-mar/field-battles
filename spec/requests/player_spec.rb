require 'rails_helper'

RSpec.describe "Players", type: :request do
  describe "POST /" do
    it "returns http success" do
      post "/players"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /current_location" do
    it "returns http success" do
      put "/players/current_location"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /status" do
    it "returns http success" do
      put "/players/status"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /players/:player_id/inventory" do
    it "returns http success" do
      put "/players/123/inventory"
      expect(response).to have_http_status(:success)
    end
  end

end