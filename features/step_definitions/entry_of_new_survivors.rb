# frozen_string_literal: true

Given('フィールドが生存者が登録できる状態になっている') do
  Item.create_initial_items
end

When('フィールドに新しい生存者を登録登録する') do
  params = build_parameters_for_registing_survivor
  post('/players', params)
end

Then('フィールドに新しい生存者を確認できる') do
  expect(only_new_survivor_exist?).to eq(true)
end

def build_parameters_for_registing_survivor
  {
    name: Faker::Japanese::Name.name,
    age: Faker::Number.between(from: 20, to: 60),
    inventory: [
      {
        name: Item.build_all_names.sample,
        count: Faker::Number.between(from: 1, to: 5)
      }
    ]
  }
end

def only_new_survivor_exist?
  fetch_filed_report[:noninfected_percentage].to_d == 1.0.to_d
end
