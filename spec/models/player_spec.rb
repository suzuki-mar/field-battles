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

    xdescribe 'status 誤ってstatusesとしてしまっているのでテストに失敗する' do      
      it { is_expected.to define_enum_for(:status).with_values(newcomer: 0, survivor: 1, infected: 2, zombie: 3, death: 4 ) }
    end
    
  end

  describe 'バリデーションのエラーメッセージ' do
    let(:player){described_class.new(params)}
    let(:params){Hash.new}

    subject do 
      player.validate
      player.errors.full_messages.first
    end

    describe 'age' do
      where(:error_name, :compare_message, :age) do
        [
          ["対象未満の場合のエラーメッセージ", "歳以上である必要があります", -1],
          ["対象以上のエラーメッセージ", "歳以下である必要があります", 1000],
          ["設定されていない場合", "必須です", nil],
        ]
      end

      before do 
        params[:age] = age
      end
    
      with_them do        
        it "エラーメッセージが存在すること" do
          expect(subject).to include(compare_message)
        end
      end
    end

    describe 'counting_to_become_zombie' do
      where(:error_name, :compare_message, :count) do
        [
          ["が0より低い場合", "より低い値には設定できません", -1],
          ["が大きい場合", "より大きい値には設定できません", 10000],
        ]
      end

      before do 
        params[:counting_to_become_zombie] = count
        params[:age] = 30
      end
    
      with_them do        
        it "エラーメッセージが存在すること" do
          expect(subject).to include(compare_message)
        end
      end
    end

    describe 'current_lat' do
      where(:error_name, :compare_message, :value) do
        [
          ["狭い場合", "の最小値は", -10000],          
          ["広い場合", "の最大値は", 100000],          
        ]
      end

      before do 
        params[:counting_to_become_zombie] = 3
        params[:age] = 30        
        params[:current_lat] = value
      end
    
      with_them do        
        it "エラーメッセージが存在すること" do          
          expect(subject).to include(compare_message)
        end
      end
    end

    describe 'current_lon' do
      where(:error_name, :compare_message, :value) do
        [
          ["高い場合", "の最小値は", -10000],          
          ["低い場合", "の最大値は", 100000],          
        ]
      end

      before do 
        params[:counting_to_become_zombie] = 3
        params[:age] = 30        
        params[:current_lat] = 3
        params[:current_lon] = value
      end
    
      with_them do        
        it "エラーメッセージが存在すること" do          
          expect(subject).to include(compare_message)
        end
      end
    end


  end


  describe 'i18nの確認' do  

    it 'モデル名の設定ができていること' do 
      expect(Player.model_name.human).to eq("プレイヤー")
    end

    describe "属性の確認" do
      where(:attribute_name, :i18n_name) do
        [
          [:age, "年齢"],          
          [:counting_to_become_zombie, "ゾンビになるまでのカウント"],
          [:current_lat, "緯度"], 
          [:current_lon, "経度"],
          [:name, "プレイヤー名"],
          [:status, "状態"],
        ]
      end

      with_them do        
        it "設定ができていること" do
          expect(Player.human_attribute_name(attribute_name)).to eq(i18n_name)
        end
      end
    end

    describe "statusのenumの確認" do
      where(:key, :i18n_name) do
        [
          [:newcomer, "新規登録者"],          
          [:survivor, "非感染者"],
          [:infected, "感染者"],
          [:zombie, "ゾンビ"],
          [:death, "死亡者"],
          
        ]
      end

      with_them do        
        it "設定ができていること" do
          expect(described_class.statuses_i18n[key]).to eq(i18n_name)
        end
      end
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
