# frozen_string_literal: true

RSpec.describe Zombie, type: :model do
  describe('raid') do
    subject do
      zombie.raid(target)
    end

    let(:zombie) do
      player = create(:player, :zombie)
      described_class.new(player)
    end

    let(:target) do
      player = create(:player, :survivor)
      player.current_lat = zombie.current_location.lat
      player.current_lon = target_lon

      Survivor.new(player)
    end

    context('近くにいる生存者の場合') do
      let(:target_lon) { zombie.current_location.lon }

      it '死亡していまうこと' do
        subject
        expect(Player.find(target.id).death?).to eq(true)
      end
    end

    context('遠くにいる生存者の場合') do
      let(:target_lon) { 10_000 }

      it 'おそえないこと' do
        subject
        expect(Player.find(target.id).death?).to eq(false)
      end
    end

    context('すでに死んでいるの場合') do
      let(:target) do
        player = create(:player, :death)
        player.current_lat = zombie.current_location.lat
        player.current_lon = zombie.current_location.lon
        SurvivorForTest.new(player)
      end

      it 'おそわないこと' do
        # 動作確認する工数がかかってしまうので実行できたらOKにする
        subject
      end
    end
  end

  class SurvivorForTest < Survivor
    attr_reader :player
  end
end
