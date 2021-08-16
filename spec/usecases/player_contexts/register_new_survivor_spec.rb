# frozen_string_literal: true

RSpec.describe PlayerContexts::RegisterNewSurvivor do
  describe 'execute' do
    subject do
      usecase = described_class.new
      usecase.execute(params)
    end

    let(:params) do
      path = Rails.root.join('spec/parameters/registe_new_survivor.json')
      json = File.open(path).read
      JSON.parse(json, { symbolize_names: true })
    end

    before do
      Item.create_initial_items
    end

    context('パラメーターが正しい場合') do
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
        expect(subject[:sucess]).to eq(true)
        expect(subject[:player]).not_to be_nil
      end
    end

    xcontext('パラメーターが不正な場合') do
      it('登録するアイテムの情報が間違っているケース')
    end
  end
end
