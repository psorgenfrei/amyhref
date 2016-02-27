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

ActiveRecord::Schema.define(version: 20160227141521) do

  create_table "hrefs", force: true do |t|
    t.text     "url"
    t.string   "domain"
    t.integer  "newsletter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "good",          default: false
    t.boolean  "good_host",     default: false
    t.boolean  "good_path",     default: false
  end

  add_index "hrefs", ["created_at"], name: "index_hrefs_on_created_at", using: :btree
  add_index "hrefs", ["domain"], name: "index_hrefs_on_domain", using: :btree
  add_index "hrefs", ["newsletter_id"], name: "index_hrefs_on_newsletter_id", using: :btree

  create_table "newsletters", force: true do |t|
    t.string   "title"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "newsletters", ["created_at"], name: "index_newsletters_on_created_at", using: :btree
  add_index "newsletters", ["email"], name: "index_newsletters_on_email", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "picture"
    t.string   "profile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
