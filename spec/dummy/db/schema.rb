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

ActiveRecord::Schema.define(version: 20150925025633) do

  create_table "assets", force: true do |t|
    t.string   "reference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assets", ["reference"], name: "index_assets_on_reference", unique: true, using: :btree

  create_table "inventory_items", force: true do |t|
    t.integer  "player_id"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: true do |t|
    t.string   "reference"
    t.integer  "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["reference"], name: "index_items_on_reference", unique: true, using: :btree

  create_table "multi_set_members", force: true do |t|
    t.integer  "multi_set_id"
    t.string   "setable_type"
    t.integer  "setable_id"
    t.integer  "weight",       default: 1
    t.integer  "quantity",     default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "multi_sets", force: true do |t|
    t.string   "reference"
    t.integer  "weight"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "multi_sets", ["reference"], name: "index_multi_sets_on_reference", unique: true, using: :btree

  create_table "players", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["name"], name: "index_players_on_name", unique: true, using: :btree

  create_table "record_tags", force: true do |t|
    t.integer  "record_id",            default: 0,     null: false
    t.string   "record_type",                          null: false
    t.string   "tag",                                  null: false
    t.boolean  "created_this_session", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "record_tags", ["record_id", "record_type"], name: "index_record_tags_on_record_id_and_record_type", using: :btree

  create_table "weapons", force: true do |t|
    t.string   "reference"
    t.integer  "damage_factor", default: 1
    t.string   "category"
    t.boolean  "ranged",        default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weapons", ["reference"], name: "index_weapons_on_reference", unique: true, using: :btree

end
