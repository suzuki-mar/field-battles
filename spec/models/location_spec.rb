# frozen_string_literal: true

RSpec.describe Location, type: :model do
  describe('can_sight?') do
    let(:location) { described_class.new(0, 0) }

    where(:lon, :lat, :expected) do
      [
        [-Location::DISTANCE_TO_SEEABLE - 0.1, 0, false],
        [Location::DISTANCE_TO_SEEABLE + 0.1, 0, false],
        [-Location::DISTANCE_TO_SEEABLE, 0, true],
        [Location::DISTANCE_TO_SEEABLE, 0, true],
        [0, -Location::DISTANCE_TO_SEEABLE - 0.1, false],
        [0, Location::DISTANCE_TO_SEEABLE + 0.1, false],
        [0, -Location::DISTANCE_TO_SEEABLE, true],
        [0, Location::DISTANCE_TO_SEEABLE, true]
      ]
    end

    with_them do
      it '判定が正しいこと' do
        compare = described_class.new(lon, lat)
        expect(location.can_sight?(compare)).to eq(expected)
      end
    end
  end
end
