# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlayerContexts::ExchangeItems do
  describe 'execute' do
    subject do
      usecase = described_class.new
      usecase.execute(survivor, params)
    end

    let(:survivor) do
      player = create(:player, :survivor)
      Survivor.new(player)
    end

    let(:params) do
      ReadJsonFile.read('spec/parameters/exchange_items.json')
    end

    before do
      Item.create_initial_items
      create_requester_inventory(survivor, params)
      create_partner_inventory(params)
    end

    context('パラメーターが正しい場合') do
      it 'アイテムの交換ができていること' do
        subject

        requester_inventory = Inventory.fetch_by_player_id(survivor.id)
        requester_item_name = params[:requeser_items].first[:name]
        expect(requester_inventory.stock_count_by_name(requester_item_name)).to eq(0)

        partner_inventory = Inventory.fetch_by_player_id(params[:partner_player_id])
        partner_item_name = params[:partner_items].first[:name]
        expect(partner_inventory.stock_count_by_name(partner_item_name)).to eq(0)
      end

      it '戻り値が正しいこと' do
        expect(subject[:sucess]).to eq(true)
      end
    end

    xcontext('パラメーターが不正な場合') do
      context('交換するアイテム分のポイントが等しくないない場合')
      context('パートナーが生存していない場合')
      context('交換しようとしたアイテムが存在しない場合')
    end
  end

  def create_requester_inventory(survivor, params)
    inventory = Inventory.fetch_by_player_id(survivor.id)

    params[:requeser_items].each do |p|
      inventory.add(p[:name], p[:count])
    end
  end

  def create_partner_inventory(params)
    player = create(:player, :survivor, id: params[:partner_player_id])
    inventory = Inventory.fetch_by_player_id(player.id)

    params[:partner_items].each do |p|
      inventory.add(p[:name], p[:count])
    end
  end
end
