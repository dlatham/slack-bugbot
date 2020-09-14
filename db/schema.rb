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

ActiveRecord::Schema.define(version: 2020_09_11_193226) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chats", force: :cascade do |t|
    t.string "dpid"
    t.string "session"
    t.string "provider"
    t.string "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jwt_tokens", force: :cascade do |t|
    t.string "addon_key"
    t.string "client_key"
    t.string "shared_secret"
    t.string "product_type"
    t.string "base_url"
    t.string "api_base_url"
    t.index ["client_key"], name: "index_jwt_tokens_on_client_key"
  end

  create_table "jwt_users", force: :cascade do |t|
    t.integer "jwt_token_id"
    t.string "user_key"
    t.string "name"
    t.string "display_name"
  end

  create_table "polls", force: :cascade do |t|
    t.string "pollname"
    t.boolean "active"
    t.boolean "open_submit"
    t.datetime "expires"
    t.json "questions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pollvotes", force: :cascade do |t|
    t.bigint "poll_id"
    t.string "username"
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_pollvotes_on_poll_id"
  end

  create_table "votes", force: :cascade do |t|
    t.string "card_id"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "pollvotes", "polls"
end
