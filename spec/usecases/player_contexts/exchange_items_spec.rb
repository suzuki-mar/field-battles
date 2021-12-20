# frozen_string_literal: true

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
      JsonParserSupport.file('spec/parameters/exchange_items.json')
    end

    before do
      SetUpper.prepare_filed
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

    context('パラメーターが不正な場合') do
      context('交換するアイテム分のポイントが等しくないない場合') do
        before do
          params[:partner_items].first[:count] = 1
        end

        it 'エラーを返すこと' do
          expect(subject[:error_keys].first).to eq(Error::Key::NOT_SAME_POINTS_TO_TRADE)
        end
      end

      context('パートナーが生存していない場合') do
        before do
          player = Player.find(params[:partner_player_id])
          player.update(status: Player.statuses[:zombie])
        end

        it 'エラーを返すこと' do
          expect(subject[:error_keys].first).to eq(Error::Key::EXCHANGE_PARTNER_NOT_SURVIVOR)
        end
      end

      xcontext('交換しようとしたアイテムが存在しない場合')
    end
  end

  def create_requester_inventory(survivor, params)
    inventory = Inventory.build_with_empty_item_stocks(survivor.id)

    params[:requeser_items].each do |p|
      inventory.add!(p[:name], p[:count])
    end
  end

  def create_partner_inventory(params)
    player = create(:player, :survivor, id: params[:partner_player_id])
    inventory = Inventory.build_with_empty_item_stocks(player.id)

    params[:partner_items].each do |p|
      inventory.add!(p[:name], p[:count])
    end
  end
end
