# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reports', type: :request do
  describe 'GET /' do
    it 'returns http success' do
      headers = { 'ACCEPT' => 'application/json' }
      get '/reports', headers: headers
      expect(response).to have_http_status(:success)
    end
  end
end
