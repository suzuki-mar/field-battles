# このシステムはなに?
荒野行動のようなバトルロワイヤルゲームをシミュレーションできるシステム
suzuki_marのポートフォリオとして作成している

キャラクター同士が自動で動き以下のようなアクションをする
* 場所の移動
* ウィルスに感染しきってゾンビになる
* ゾンビになってキャラクターを襲う

その他にもキャラクターができることを増やしていく


# 今後の機能追加予定
* アイテムを使用できるようにする
* フィールドにターンの概念の導入をしたい
* 行動を記録したい
* コンソールで操作できるようにしたい
* フィールドをリセットできるようにしたい

# 修正(リファクタリング)したいこと
* Playerという名前のモデルをCharacterに変更したい
* Usecaseを使用しているところを削除したい
* RESTfulではないエンドポイントの修正
* 全プレイヤーのインベントリを管理しているトレードセンターを作成したい

