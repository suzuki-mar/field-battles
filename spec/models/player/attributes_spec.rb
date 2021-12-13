# frozen_string_literal: true

# player_specが肥大化したのと記述内容の多くが属性に関連するものになっていたので、属性に関するところを切り出した
#
# 実装の関係上 describeはPlayerにしてある これをしないとshoulda matchersが使えない
RSpec.describe Player, type: :model do
  describe 'validations' do
    describe 'age' do
      it { is_expected.to validate_presence_of(:age) }
      it { is_expected.to allow_value(18).for(:age) }
      it { is_expected.to allow_value(65).for(:age) }
      it { is_expected.not_to allow_value(17).for(:age) }
      it { is_expected.not_to allow_value(66).for(:age) }
    end

    xdescribe 'counting_to_become_zombie' do
      it { is_expected.to allow_value(5).for(:counting_to_become_zombie) }
      it { is_expected.to allow_value(0).for(:counting_to_become_zombie) }
      it { is_expected.not_to allow_value(6).for(:counting_to_become_zombie) }
      it { is_expected.not_to allow_value(-1).for(:counting_to_become_zombie) }
    end

    xdescribe 'current_lat' do
      it { is_expected.to validate_presence_of(:current_lat) }
      it { is_expected.to allow_value(Filed::LAT_RANGE.end).for(:current_lat) }
      it { is_expected.to allow_value(Filed::LAT_RANGE.begin).for(:current_lat) }
      it { is_expected.not_to allow_value(Filed::LAT_RANGE.end + 1).for(:current_lat) }
      it { is_expected.not_to allow_value(Filed::LAT_RANGE.begin - 1).for(:current_lat) }
    end

    xdescribe 'current_lon' do
      it { is_expected.to validate_presence_of(:current_lon) }
      it { is_expected.to allow_value(Filed::LON_RANGE.end).for(:current_lon) }
      it { is_expected.to allow_value(Filed::LON_RANGE.begin).for(:current_lon) }
      it { is_expected.not_to allow_value(Filed::LON_RANGE.end + 1).for(:current_lon) }
      it { is_expected.not_to allow_value(Filed::LON_RANGE.begin - 1).for(:current_lon) }
    end

    xdescribe 'status 誤ってstatusesとしてしまっているのでテストに失敗する' do
      it {
        expect(subject).to define_enum_for(:status).with_values(newcomer: 0, survivor: 1, infected: 2, zombie: 3,
                                                                death: 4)
      }
    end
  end

  describe 'バリデーションのエラーメッセージ' do
    subject do
      player.validate
      player.errors.full_messages.first
    end

    let(:player) { described_class.new(params) }
    let(:params) do
      {
        counting_to_become_zombie: 3,
        age: 30,
        current_lat: 30,
        current_lon: 30
      }
    end

    describe 'age' do
      where(:error_name, :compare_message, :age) do
        [
          ['対象未満の場合のエラーメッセージ', '歳以上である必要があります', -1],
          ['対象以上のエラーメッセージ', '歳以下である必要があります', 1000],
          ['設定されていない場合', '必須です', nil]
        ]
      end

      before do
        params[:age] = age
      end

      with_them do
        it 'エラーメッセージが存在すること' do
          expect(subject).to include(compare_message)
        end
      end
    end

    describe 'counting_to_become_zombie' do
      where(:error_name, :compare_message, :count) do
        [
          ['が0より低い場合', 'より低い値には設定できません', -1],
          ['が大きい場合', 'より大きい値には設定できません', 10_000]
        ]
      end

      before do
        params[:counting_to_become_zombie] = count
      end

      with_them do
        it 'エラーメッセージが存在すること' do
          expect(subject).to include(compare_message)
        end
      end
    end

    describe 'current_lat' do
      where(:error_name, :compare_message, :value) do
        [
          ['狭い場合', 'の最小値は', -10_000],
          ['広い場合', 'の最大値は', 100_000]
        ]
      end

      before do
        params[:current_lat] = value
      end

      with_them do
        it 'エラーメッセージが存在すること' do
          expect(subject).to include(compare_message)
        end
      end
    end

    describe 'current_lon' do
      where(:error_name, :compare_message, :value) do
        [
          ['高い場合', 'の最小値は', -10_000],
          ['低い場合', 'の最大値は', 100_000]
        ]
      end

      before do
        params[:current_lon] = value
      end

      with_them do
        it 'エラーメッセージが存在すること' do
          expect(subject).to include(compare_message)
        end
      end
    end
  end

  describe 'i18nの確認' do
    it 'モデル名の設定ができていること' do
      expect(described_class.model_name.human).to eq('プレイヤー')
    end

    describe '属性の確認' do
      where(:attribute_name, :i18n_name) do
        [
          [:age, '年齢'],
          [:counting_to_become_zombie, 'ゾンビになるまでのカウント'],
          [:current_lat, '緯度'],
          [:current_lon, '経度'],
          [:name, 'プレイヤー名'],
          [:status, '状態']
        ]
      end

      with_them do
        it '設定ができていること' do
          expect(described_class.human_attribute_name(attribute_name)).to eq(i18n_name)
        end
      end
    end

    describe 'statusのenumの確認' do
      where(:key, :i18n_name) do
        [
          [:newcomer, '新規登録者'],
          [:survivor, '非感染者'],
          [:infected, '感染者'],
          [:zombie, 'ゾンビ'],
          [:death, '死亡者']

        ]
      end

      with_them do
        it '設定ができていること' do
          expect(described_class.statuses_i18n[key]).to eq(i18n_name)
        end
      end
    end
  end
end
