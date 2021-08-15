# frozen_string_literal: true

RSpec.describe Filed, type: :model do
  describe('load_survivors') do
    subject do
      filed.load_survivors
    end

    let!(:player) { create(:player, :survivor) }
    let(:filed) { FiledForTest.new }

    before do
      create(:player, :zombie)
      create(:player, :infected)
    end

    it('生存者だけを取得すること') do
      subject
      expect(filed.survivors.count).to eq(2)
      expect(filed.survivors.first.id).to eq(player.id)
    end
  end

  describe('turning_into_infected') do
    subject do
      filed.turning_into_infected
    end

    let(:filed) { FiledForTest.new }
    let(:survivors) do
      players = create_list(:player, 2, :survivor)
      players.map { |p| Survivor.new(p) }
    end

    before do
      allow(survivors.first).to receive(:turn_into_infected?).and_return(false)
      allow(survivors.second).to receive(:turn_into_infected?).and_return(true)

      filed.survivors = survivors
    end

    it '感染してしまう生存者が存在すること' do
      subject
      expect(survivors.first.infected?).to eq(false)
      expect(survivors.second.infected?).to eq(true)
    end
  end

  describe('progress_of_infection') do
    subject do
      filed.progress_of_infection
    end

    let(:filed) { FiledForTest.new }
    let(:infected) { Survivor.new(create(:player, :infected)) }

    before do
      noninfected = Survivor.new(create(:player, :survivor))
      filed.survivors = [noninfected, infected]
    end

    it '感染状態が進展すること' do
      before_count = infected.counting_to_become_zombie
      subject
      after_count = Player.select(:counting_to_become_zombie).where(id: infected.id).first[:counting_to_become_zombie]
      expect(after_count).to be < before_count
    end
  end

  describe('progress_of_zombification') do
    subject do
      filed.progress_of_zombification
    end

    let(:filed) { FiledForTest.new }
    let(:infected) { Survivor.new(create(:player, :infection_complete)) }

    before do
      infected.counting_to_become_zombie.times do |_i|
        infected.progress_of_zombie
      end

      filed.survivors = [infected]
    end

    it '感染完了者がゾンビになっていること' do
      subject
      expect(Player.find(infected.id).status).to eq(Player.statuses[:zombie])
    end
  end

  # テストをかんたんにするため
  class FiledForTest < Filed
    attr_accessor :survivors
  end
end
