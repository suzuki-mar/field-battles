Feature: 新しい生存者の登録をする
  アイテムなどを所持している生存者を登録する

  Scenario: フィールドに新しい生存者を登録する
    Given フィールドが生存者が登録できる状態になっている
    When フィールドに新しい生存者を登録登録する
    Then フィールドに新しい生存者を確認できる
