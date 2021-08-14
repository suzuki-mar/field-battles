# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_14_051020) do

  create_table "item_stocks", force: :cascade do |t|
    t.integer "stock_count", null: false
    t.integer "item_id"
    t.integer "player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_item_stocks_on_item_id"
    t.index ["player_id"], name: "index_item_stocks_on_player_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.integer "kind", null: false
    t.integer "effect_value", null: false
    t.integer "point", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.integer "age", null: false
    t.integer "status", null: false
    t.integer "counting_to_starvation", null: false
    t.integer "counting_to_become_zombie", null: false
    t.float "current_lon", null: false
    t.float "current_lat", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tests", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "item_stocks", "items"
  add_foreign_key "item_stocks", "players"
end
