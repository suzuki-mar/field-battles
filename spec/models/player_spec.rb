# frozen_string_literal: true

# == Schema Information
#
# Table name: players
#
#  id                        :integer          not null, primary key
#  age                       :integer          not null
#  counting_to_become_zombie :integer          not null
#  current_lat               :float            not null
#  current_lon               :float            not null
#  name                      :string           not null
#  status                    :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

RSpec.describe Player, type: :model do
  describe 'validations' do
    describe 'age' do
      it { is_expected.to validate_presence_of(:age) }
      it { is_expected.to allow_value(18).for(:age) }
      it { is_expected.to allow_value(65).for(:age) }
      it { is_expected.not_to allow_value(17).for(:age) }
      it { is_expected.not_to allow_value(66).for(:age) }
    end

    describe 'counting_to_become_zombie' do
      it { is_expected.to allow_value(5).for(:counting_to_become_zombie) }
      it { is_expected.to allow_value(0).for(:counting_to_become_zombie) }
      it { is_expected.not_to allow_value(6).for(:counting_to_become_zombie) }
      it { is_expected.not_to allow_value(-1).for(:counting_to_become_zombie) }
    end

    describe 'current_lat' do
      it { is_expected.to validate_presence_of(:current_lat) }
      it { is_expected.to allow_value(Filed::LAT_RANGE.end).for(:current_lat) }
      it { is_expected.to allow_value(Filed::LAT_RANGE.begin).for(:current_lat) }
      it { is_expected.not_to allow_value(Filed::LAT_RANGE.end + 1).for(:current_lat) }
      it { is_expected.not_to allow_value(Filed::LAT_RANGE.begin - 1).for(:current_lat) }
    end

    describe 'current_lon' do
      it { is_expected.to validate_presence_of(:current_lon) }
      it { is_expected.to allow_value(Filed::LON_RANGE.end).for(:current_lon) }
      it { is_expected.to allow_value(Filed::LON_RANGE.begin).for(:current_lon) }
      it { is_expected.not_to allow_value(Filed::LON_RANGE.end + 1).for(:current_lon) }
      it { is_expected.not_to allow_value(Filed::LON_RANGE.begin - 1).for(:current_lon) }
    end
  end

  describe 'current_location' do
    let(:player) { create(:player) }

    # subject{player.current_location}

    it do
      expect(player.current_location).not_to be_nil
    end
  end

  describe 'can_see?' do
    subject { player.can_see?(target) }

    let(:player) { create(:player, current_lon: 0) }
    let(:target) do
      create(:player, current_lon: lon)
    end

    context '見ることができる場合' do
      let(:lon) { player.current_lon }

      it 'trueが返ること' do
        expect(subject).to eq(true)
      end
    end

    context '見ることができない場合' do
      let(:lon) { player.current_lon + 50 }

      it 'falseが返ること' do
        expect(subject).to eq(false)
      end
    end
  end
end
