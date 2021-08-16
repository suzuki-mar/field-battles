# frozen_string_literal: true

# == Schema Information
#
# Table name: players
#
#  id                        :integer          not null, primary key
#  age                       :integer          not null
#  counting_to_become_zombie :integer          not null
#  counting_to_starvation    :integer          not null
#  current_lat               :float            not null
#  current_lon               :float            not null
#  name                      :string           not null
#  status                    :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

RSpec.describe Player, type: :model do
  describe 'current_location' do 
    let(:player) {create(:player)}
    
    # subject{player.current_location}

    it do 
      expect(player.current_location).not_to be_nil
    end
  end

end

describe 'can_see?' do 
  let(:player) {create(:player)}
  let(:target) do
    create(:player, current_lon:lon)
  end

  subject{player.can_see?(target)}

  context '見ることができる場合' do 
    let(:lon){player.current_lon}

    it 'trueが返ること' do 
      is_expected.to eq(true)
    end
  end

  context '見ることができない場合' do 
    let(:lon){player.current_lon + 1000}

    it 'falseが返ること' do 
      is_expected.to eq(false)
    end
  end

  
end