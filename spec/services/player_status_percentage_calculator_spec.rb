# frozen_string_literal: true

RSpec.describe PlayerStatusPercentageCalculator do
  describe 'execute' do
    subject do
      service = described_class.new
      filed = Filed.new
      filed.load_survivors

      service.execute(Player.all, filed)
    end

    context 'すべての状態のプレイヤーが存在する場合' do
      before do
        create_list(:player, 6, :survivor)
        create_list(:player, 5, :infected)
        create_list(:player, 3, :zombie)
      end

      it '非感染者の割合を取得できていること' do
        expect(subject[:noninfected_percentage]).to eq(0.429)
      end

      it '感染者の割合を取得できていること' do
        expect(subject[:infected_percentage]).to eq(0.357)
      end

      it 'ゾンビを含む感染者の割合を取得できていること' do
        expect(subject[:infected_percentage_including_zombies]).to eq(0.571)
      end
    end

    context '一部のステータスの状態のプレイヤーが存在しない場合' do
      before do
        create_list(:player, 5, :infected)
        create_list(:player, 3, :zombie)
      end

      it 'ゼロ除算にならないこと' do
        expect(subject[:noninfected_percentage]).to eq(0)
      end
    end
  end
end
