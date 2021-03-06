# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160613141749) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "last_4_digits"
    t.string   "expiry"
    t.string   "network"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

  create_table "journeys", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "from"
    t.string   "to"
    t.date     "date"
    t.string   "time"
    t.integer  "fare"
    t.string   "mondo_transaction_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "card_id"
    t.integer  "tapped_in_mod"
    t.integer  "tapped_out_mod"
  end

  add_index "journeys", ["user_id"], name: "index_journeys_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "token"
    t.string   "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "encrypted_tfl_username"
    t.string   "encrypted_tfl_username_iv"
    t.string   "encrypted_tfl_password"
    t.string   "encrypted_tfl_password_iv"
    t.integer  "current_card_id"
  end

  add_index "users", ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  add_foreign_key "cards", "users"
  add_foreign_key "journeys", "users"
end
