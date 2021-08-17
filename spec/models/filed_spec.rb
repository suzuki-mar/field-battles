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

  describe('load_zomibe') do
    subject do
      filed.load_zombies
    end

    let!(:player) { create(:player, :zombie) }
    let(:filed) { FiledForTest.new }

    before do
      create(:player, :infected)
    end

    it('ゾンビだけを取得すること') do
      subject
      expect(filed.zombies.count).to eq(1)
      expect(filed.zombies.first.id).to eq(player.id)
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

  describe('move_the_survivor') do
    subject do
      filed.move_the_survivors
    end

    let(:filed) { FiledForTest.new }
    let(:player) do
      player = create(:player, :survivor)
      player.current_lon = Filed::LON_RANGE.first
      player
    end
    let(:survivor) { Survivor.new(player) }

    before do
      filed.survivors = [survivor]
    end

    it '移動していること' do
      subject
      expect(survivor.current_location.lon).to be > Filed::LON_RANGE.first
    end
  end

  describe('can_move?') do
    subject do
      survivor = Survivor.new(player)
      filed.can_move?(survivor)
    end

    let(:filed) { FiledForTest.new }
    let(:player) do
      player = create(:player, :survivor)
      player.current_lon = lon
      player
    end
    let(:survivor) { Survivor.new(create(:player, :survivor)) }

    before do
      filed.survivors = [survivor]
    end

    context 'フィールドの区域内の移動の場合' do
      let(:lon) { Filed::LON_RANGE.first }

      it 'trueが返ること' do
        expect(subject).to eq(true)
      end
    end

    context 'フィールドの区域外の移動の場合' do
      let(:lon) { Filed::LON_RANGE.first - 1 }

      it 'trueが返ること' do
        expect(subject).to eq(false)
      end
    end
  end

  describe('attack_of_zombies') do
    subject do
      filed.attack_of_zombies
    end

    let(:filed) { FiledForTest.new }
    let(:player) do
      zombie_player = create(:player, :zombie)

      player = create(:player, :survivor)
      player.current_lon = zombie_player.current_location.lon
      player.current_lat = zombie_player.current_location.lat
      player.save
      player
    end
    let(:survivor) { Survivor.new(player) }

    before do
      filed.survivors = [survivor]
    end

    it 'ゾンビが襲撃していること' do
      subject
      expect(Player.find(survivor.id).status).to eq(Player.statuses[:death])
    end
  end

  # テストをかんたんにするため
  class FiledForTest < described_class
    attr_accessor :survivors
  end
end
