# frozen_string_literal: true

RSpec.describe FiledContext::WorseningOfInfection do
  describe 'execute' do
    subject do
      usecase.execute
    end

    let(:usecase) { WorseningOfInfectionForTest.new }

    before do
      # 一人は感染する感染する生存者を発生させたいので多めに作成している
      create_list(:player, 20, :survivor)
    end

    it 'ゾンビになった生存者がいること' do
      subject

      expect(Player.exists?(status: Player.statuses[:zombie])).to eq(true)
    end

    it '戻り値が正しいこと' do
      expect(subject).to eq(true)
    end
  end

  class WorseningOfInfectionForTest < described_class
    attr_reader :filed
  end
end
