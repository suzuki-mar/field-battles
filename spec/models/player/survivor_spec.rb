# frozen_string_literal: true

RSpec.describe Player::Survivor, type: :model do
  describe('infected?') do
    subject do
      survivor.become_infected!
    end

    before do
      SetUpper.prepare_items
      inventory = Inventory.build_with_empty_item_stocks(survivor.id)
      inventory.add!(Item::Name::AK47, 1)
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

  describe('turn_into_infected?') do
    subject { survivor.turn_into_infected? }

    let(:survivor) do
      player = create(:player, :survivor)
      described_class.new(player)
    end

    context '確率にあたってしまった場合' do
      before do
        allow(survivor).to receive(:random).and_return(0)
      end

      it('trueが返ること') do
        expect(subject).to eq(true)
      end
    end

    context '確率にあたっていない場合' do
      before do
        allow(survivor).to receive(:random).and_return(1)
      end

      it('falseが返ること') do
        expect(subject).to eq(false)
      end
    end
  end

  describe('become_infected!') do
    subject { noninfected.become_infected! }

    let(:noninfected) do
      player = create(:player, :noninfected)
      described_class.new(player)
    end

    let(:inventory) do
      Inventory.build_with_empty_item_stocks(noninfected.id)
    end

    before do
      SetUpper.prepare_items
      inventory.add!(Item::Name::AK47, 1)
    end

    context('回復用アイテムがある場合') do
      before do
        inventory.add!(Item::Name::FIRST_AID_POUCH, 1)
      end

      it('非感染者のままであること') do
        subject
        expect(noninfected.noninfected?).to eq(true)
      end

      it('アイテムを消費していること') do
        subject
        expect(inventory.has_item?(Item::Name::FIRST_AID_POUCH)).to eq(false)
      end
    end

    context('アイテムがない場合') do
      it('感染者になっていること') do
        subject
        expect(noninfected.infected?).to eq(true)
      end
    end
  end

  describe('report_infected_players!') do
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
        survivor.report_infected_players!([infected_survivor])
      end

      context '見える距離の場合' do
        before do
          allow_any_instance_of(Location).to receive(:can_sight?).and_return(true)
        end

        it '感染している生存者の感染状態が進むこと' do
          subject
          expect(infected_survivor.counting_to_become_zombie).to eq(Player::COUNT_OF_BEFORE_BECOMING_ZOMBIE - 1)
        end
      end

      context '見えない距離の場合' do
        before do
          allow_any_instance_of(Location).to receive(:can_sight?).and_return(false)
        end

        it '感染状態は進まないこと' do
          subject
          expect(infected_survivor.counting_to_become_zombie).to eq(Player::COUNT_OF_BEFORE_BECOMING_ZOMBIE)
        end
      end
    end

    context '自分が報告対象になっている場合' do
      subject do
        infected_survivor.report_infected_players!([infected_survivor])
      end

      it '感染状態はすすまないこと' do
        subject
        expect(infected_survivor.counting_to_become_zombie).to eq(Player::COUNT_OF_BEFORE_BECOMING_ZOMBIE)
      end
    end
  end

  describe('progress_of_zombie!') do
    subject do
      survivor.progress_of_zombie!
    end

    let(:survivor) do
      described_class.new(player)
    end

    context('感染者の場合') do
      let(:player) { create(:player, :infected) }

      it 'ゾンビ化が近づく' do
        subject
        player = Player.find(survivor.id)
        expect(player.counting_to_become_zombie).to eq(Player::COUNT_OF_BEFORE_BECOMING_ZOMBIE - 1)
      end
    end

    context('すでにゾンビ化してしまった場合') do
      let(:player) { create(:player, :zombie) }

      it 'カウントは減少しない' do
        subject
        expect(survivor.counting_to_become_zombie).to eq(0)
      end
    end

    context('感染していない場合') do
      let(:player) { create(:player, :noninfected) }

      it '例外が発生すること' do
        expect { subject }.to raise_error(ActiveRecord::Rollback)
      end

      it 'エラーがセットされること' do
        ActiveRecord::Base.transaction do
          subject
        end

        expect(survivor.errors.present?).to eq(true)
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
          survivor.progress_of_zombie!
        end
      end

      it 'trueが返ること' do
        expect(subject).to eq(true)
      end
    end

    context '進行が完了してしいない場合' do
      before do
        survivor.progress_of_zombie!
      end

      it 'falseが返ること' do
        expect(subject).to eq(false)
      end
    end
  end

  describe('become_zombie!') do
    subject { survivor.become_zombie! }

    let(:survivor) do
      player = create(:player, :infected)
      described_class.new(player)
    end

    context 'ゾンビになる状況の場合' do
      let(:player) { create(:player, :infection_complete) }

      before do
        survivor.counting_to_become_zombie.times do |_i|
          survivor.progress_of_zombie!
        end
      end

      it '戻り値がtrueなこと' do
        expect(subject).to eq(true)
      end

      it 'ゾンビになっていること' do
        subject
        expect(Player.find(survivor.id).zombie?).to eq(true)
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

  class SurvivorForTest < described_class
    attr_reader :player
  end
end
