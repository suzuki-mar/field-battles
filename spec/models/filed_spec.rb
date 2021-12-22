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

  xdescribe('turning_into_infected') do
  end

  describe 'infection_progresses!' do
    subject do
      filed.infection_progresses!
    end

    let(:filed) { FiledForTest.new }

    before do
      SetUpper.prepare_items

      player_ids.each do |id|
        inventory = Inventory.build_with_empty_item_stocks(id)
        inventory.add!(Item::Name::AK47, 1)
      end
    end

    context '感染していまう感染者が存在する場合' do
      let(:noninfecteds) do
        players = create_list(:player, 2, :noninfected)
        players.map { |p| Player::Survivor.new(p) }
      end

      let(:player_ids) do
        noninfecteds.map(&:id)
      end

      before do
        allow(noninfecteds.first).to receive(:turn_into_infected?).and_return(false)
        allow(noninfecteds.second).to receive(:turn_into_infected?).and_return(true)

        filed.survivors = noninfecteds
      end

      it '感染者になること' do
        subject
        expect(noninfecteds.first.infected?).to eq(false)
        expect(noninfecteds.second.infected?).to eq(true)
      end
    end

    context '感染者が存在する場合' do
      let(:infected) { Player::Survivor.new(create(:player, :infected)) }
      let(:noninfected) do
        Player::Survivor.new(create(:player, :noninfected))
      end
      let(:player_ids) do
        [noninfected.id, infected.id]
      end

      before do
        filed.survivors = [noninfected, infected]
      end

      it '感染状態が進展すること' do
        before_count = infected.counting_to_become_zombie
        subject
        after_count = Player.select(:counting_to_become_zombie).where(id: infected.id).first[:counting_to_become_zombie]
        expect(after_count).to be < before_count
      end
    end

    context 'ゾンビになる感染者が存在する場合' do
      let(:filed) { FiledForTest.new }
      let(:infected) { Player::Survivor.new(create(:player, :infection_complete)) }

      let(:player_ids) do
        [infected.id]
      end

      before do
        infected.counting_to_become_zombie.times do |_i|
          infected.progress_of_zombie
        end

        filed.survivors = [infected]
      end

      it '感染完了者がゾンビになっていること' do
        subject
        expect(Player.find(infected.id).zombie?).to eq(true)
      end
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
    let(:survivor) { Player::Survivor.new(player) }

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
      survivor = Player::Survivor.new(player)
      filed.can_move?(survivor)
    end

    let(:filed) { FiledForTest.new }
    let(:player) do
      player = create(:player, :survivor)
      player.current_lon = lon
      player
    end
    let(:survivor) { Player::Survivor.new(create(:player, :survivor)) }

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
    let(:survivor) { Player::Survivor.new(player) }

    before do
      filed.survivors = [survivor]
    end

    it 'ゾンビが襲撃していること' do
      subject
      expect(Player.find(survivor.id).death?).to eq(true)
    end
  end

  # テストをかんたんにするため
  class FiledForTest < described_class
    attr_accessor :survivors
  end
end
