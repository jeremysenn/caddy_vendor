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

ActiveRecord::Schema.define(version: 20161212151823) do

  create_table "caddies", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "caddies_clubs", id: false, force: :cascade do |t|
    t.integer "caddy_id", null: false
    t.integer "club_id",  null: false
    t.index ["caddy_id"], name: "index_caddies_clubs_on_caddy_id"
    t.index ["club_id"], name: "index_caddies_clubs_on_club_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  create_table "clubs_members", id: false, force: :cascade do |t|
    t.integer "club_id",   null: false
    t.integer "member_id", null: false
    t.index ["club_id"], name: "index_clubs_members_on_club_id"
    t.index ["member_id"], name: "index_clubs_members_on_member_id"
  end

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.datetime "start"
    t.datetime "end"
    t.string   "color"
    t.string   "size"
    t.string   "round"
    t.text     "notes"
    t.integer  "club_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "status"
    t.index ["club_id"], name: "index_events_on_club_id"
  end

  create_table "members", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "caddy_id"
    t.integer  "event_id"
    t.string   "caddy_type"
    t.decimal  "fee",        precision: 7, scale: 2
    t.decimal  "tip",        precision: 7, scale: 2
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["caddy_id"], name: "index_players_on_caddy_id"
    t.index ["event_id"], name: "index_players_on_event_id"
    t.index ["member_id"], name: "index_players_on_member_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
