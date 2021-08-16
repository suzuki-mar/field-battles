# frozen_string_literal: true

RSpec.describe Survivor, type: :model do
  describe('infected?') do
    subject do
      survivor.become_infected
    end

    let(:survivor) do
      player = create(:player, :survivor)
      described_class.new(player)
    end

    it '感染状態になること' do
      subject
      expect(survivor.infected?).to eq(true)
    end
  end

  describe('rturn_into_infected?') do
    subject { survivor.turn_into_infected? }

    # 最初に0が返るのに乱数を設定する
    let!(:rand_seed) { srand }

    before do
      srand(123)
    end

    after do
      srand(rand_seed)
    end

    context('アイテムがある場合') do
      xit('falseが返りアイテムを使用していること')
    end

    context('アイテムがない場合で確率があたってしまった場合') do
      let(:survivor) do
        player = create(:player, :survivor)
        described_class.new(player)
      end

      it('trueが返ること') do
        srand(rand_seed)
      end
    end
  end

  describe('report_infected_players') do
    let(:survivor) do
      player = create(:player, :survivor)
      described_class.new(player)
    end

    let(:infected_survivor) do
      player = create(:player, :infected)
      described_class.new(player)
    end

    context '別の人に実行する場合' do
      subject do
        survivor.report_infected_players([infected_survivor])
      end

      it '感染している生存者の感染状態が進むこと' do
        subject
        expect(infected_survivor.counting_to_become_zombie).to eq(Player::COUNT_OF_BEFORE_BECOMING_ZOMBIE - 1)
      end
    end

    context '自分が報告対象になっている場合' do
      subject do
        infected_survivor.report_infected_players([infected_survivor])
      end

      it '感染状態はすすまないこと' do
        subject
        expect(infected_survivor.counting_to_become_zombie).to eq(Player::COUNT_OF_BEFORE_BECOMING_ZOMBIE)
      end
    end
  end

  describe('progress_of_zombie') do
    xit '感染していない生存者に実行した場合にエラーを発生する'

    subject do
      survivor.progress_of_zombie
    end

    let(:survivor) do
      described_class.new(player)
    end

    context('まだゾンビ化していない場合') do
      let(:player) { create(:player, :infected) }

      it 'ゾンビ化が近づく' do
        subject
        expect(survivor.counting_to_become_zombie).to eq(Player::COUNT_OF_BEFORE_BECOMING_ZOMBIE - 1)
      end
    end

    context('すでにゾンビ化してしまった場合') do
      let(:player) { create(:player, :zombie) }

      it 'カウントは減少しない' do
        subject
        expect(survivor.counting_to_become_zombie).to eq(0)
      end
    end
  end

  describe('fully_infected?') do
    subject { survivor.fully_infected? }

    let(:survivor) do
      player = create(:player, :infected)
      described_class.new(player)
    end

    context '進行が完了してしまっている場合' do
      before do
        survivor.counting_to_become_zombie.times do |_i|
          survivor.progress_of_zombie
        end
      end

      it 'trueが返ること' do
        expect(subject).to eq(true)
      end
    end

    context '進行が完了してしいない場合' do
      before do
        survivor.progress_of_zombie
      end

      it 'falseが返ること' do
        expect(subject).to eq(false)
      end
    end
  end

  describe('become_zombie') do
    subject { survivor.become_zombie }

    let(:survivor) do
      player = create(:player, :infected)
      described_class.new(player)
    end

    context 'ゾンビになる状況の場合' do
      let(:player) { create(:player, :infection_complete) }

      before do
        survivor.counting_to_become_zombie.times do |_i|
          survivor.progress_of_zombie
        end
      end

      it '戻り値がtrueなこと' do
        expect(subject).to eq(true)
      end

      it 'ゾンビになっていること' do
        subject
        expect(Player.find(survivor.id).status).to eq(Player.statuses[:zombie])
      end
    end

    context 'ゾンビにならない場合' do
      let(:player) { create(:player, :infected) }

      it '戻り値がfalseなこと' do
        expect(subject).to eq(false)
      end

      it 'ゾンビになっていないこと' do
        subject
        expect(Player.find(survivor.id).status).not_to eq(Player.statuses[:zombie])
      end
    end
  end

  describe('assign_next_locations') do
    subject { survivor.assign_next_locations }

    let(:survivor) do
      player = create(:player, :survivor)
      SurvivorForTest.new(player)
    end

    it '次に移動する場所を設定されていること' do
      before_location = { lat: survivor.player.current_lat, lon: survivor.player.current_lon }
      subject
      after_location = { lat: survivor.player.current_lat, lon: survivor.player.current_lon }
      expect(before_location[:lat]).not_to eq(after_location[:lat])
      expect(before_location[:lon]).not_to eq(after_location[:lon])
    end
  end

  class SurvivorForTest < Survivor
    attr_reader :player
  end
end
