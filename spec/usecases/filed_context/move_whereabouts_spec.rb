# frozen_string_literal: true

RSpec.describe FiledContext::MoveWhereabouts do
  describe 'execute' do
    subject do
      usecase.execute
    end

    let(:usecase) { described_class.new }
    let(:survivor_player) { create(:player, :survivor) }

    before do
      zombie_player = create(:player, :zombie)
      survivor_player.update(current_lat: zombie_player.current_lat, current_lon: zombie_player.current_lon)
      allow_any_instance_of(Location).to receive(:can_sight?).and_return(true)
    end

    it '移動していること' do
      before_location = survivor_player.current_location
      subject
      after_location = survivor_player.reload.current_location

      expect(after_location.equal(before_location)).to eq(false)
    end

    it 'ゾンビに襲われていること' do
      subject
      expect(Player.find(survivor_player.id).status).to eq(Player.statuses[:death])
    end

    it '戻り値が正しいこと' do
      expect(subject).to eq(true)
    end
  end
end
