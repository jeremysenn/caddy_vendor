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

ActiveRecord::Schema.define(version: 20171227194122) do

  create_table "caddy_ratings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "caddy_id"
    t.integer  "user_id"
    t.string   "comment"
    t.integer  "score",            default: 0
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "player_id"
    t.integer  "appearance_score", default: 0
    t.integer  "enthusiasm_score", default: 0
    t.index ["caddy_id"], name: "index_caddy_ratings_on_caddy_id", using: :btree
    t.index ["user_id"], name: "index_caddy_ratings_on_user_id", using: :btree
  end

  create_table "events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.datetime "start"
    t.datetime "end"
    t.string   "color"
    t.string   "size"
    t.string   "round"
    t.string   "status",                   default: "open"
    t.text     "notes",      limit: 65535
    t.integer  "course_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["course_id"], name: "index_events_on_course_id", using: :btree
  end

  create_table "players", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "member_id"
    t.integer  "caddy_id"
    t.integer  "event_id"
    t.string   "caddy_type"
    t.string   "status"
    t.integer  "round"
    t.decimal  "fee",             precision: 7, scale: 2
    t.decimal  "tip",             precision: 7, scale: 2
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "note"
    t.decimal  "transaction_fee", precision: 7, scale: 2
    t.index ["caddy_id"], name: "index_players_on_caddy_id", using: :btree
    t.index ["event_id"], name: "index_players_on_event_id", using: :btree
    t.index ["member_id"], name: "index_players_on_member_id", using: :btree
  end

  create_table "sms_messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "to"
    t.text     "body",        limit: 65535
    t.integer  "customer_id"
    t.integer  "caddy_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "company_id"
  end

  create_table "transfers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "from_account_id"
    t.integer  "to_account_id"
    t.integer  "customer_id"
    t.integer  "player_id"
    t.integer  "caddy_fee_cents"
    t.integer  "caddy_tip_cents"
    t.integer  "amount_cents"
    t.integer  "fee_cents"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "ez_cash_tran_id"
    t.boolean  "reversed",                   default: false
    t.integer  "fee_to_account_id"
    t.boolean  "member_balance_cleared",     default: false
    t.integer  "company_id"
    t.string   "note"
    t.integer  "club_credit_transaction_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "",                           null: false
    t.string   "encrypted_password",     default: "",                           null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "company_id"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.string   "time_zone",              default: "Eastern Time (US & Canada)"
    t.boolean  "active",                 default: false
    t.string   "role"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
