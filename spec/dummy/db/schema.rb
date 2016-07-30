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

ActiveRecord::Schema.define(version: 20160730032504) do

  create_table "assets", force: :cascade do |t|
    t.string   "reference",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assets", ["reference"], name: "index_assets_on_reference", unique: true, using: :btree

  create_table "inventory_items", force: :cascade do |t|
    t.integer  "player_id",  limit: 4
    t.integer  "item_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: :cascade do |t|
    t.string   "reference",  limit: 255
    t.integer  "asset_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["reference"], name: "index_items_on_reference", unique: true, using: :btree

  create_table "multi_set_members", force: :cascade do |t|
    t.integer  "multi_set_id", limit: 4
    t.string   "setable_type", limit: 255
    t.integer  "setable_id",   limit: 4
    t.integer  "weight",       limit: 4,   default: 1
    t.integer  "quantity",     limit: 4,   default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "multi_sets", force: :cascade do |t|
    t.string   "reference",  limit: 255
    t.integer  "weight",     limit: 4
    t.integer  "quantity",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "multi_sets", ["reference"], name: "index_multi_sets_on_reference", unique: true, using: :btree

  create_table "player_infos", force: :cascade do |t|
    t.integer "player_id", limit: 4,   null: false
    t.string  "key",       limit: 255, null: false
    t.string  "value",     limit: 255
  end

  create_table "players", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["name"], name: "index_players_on_name", unique: true, using: :btree

  create_table "record_tags", force: :cascade do |t|
    t.string   "record_id",            limit: 255, default: "0",   null: false
    t.string   "record_type",          limit: 255,                 null: false
    t.string   "candidate_key",        limit: 255,                 null: false
    t.string   "tag",                  limit: 255,                 null: false
    t.boolean  "created_this_session",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "record_tags", ["record_id", "record_type"], name: "index_record_tags_on_record_id_and_record_type", using: :btree

  create_table "skill_effect2s", force: :cascade do |t|
    t.string   "reference",       limit: 255
    t.string   "skill_reference", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "skill_types", force: :cascade do |t|
    t.string   "reference",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string   "reference",     limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "skill_type_id", limit: 4
  end

  create_table "weapons", force: :cascade do |t|
    t.string   "reference",     limit: 255
    t.integer  "damage_factor", limit: 4,   default: 1
    t.string   "category",      limit: 255
    t.boolean  "ranged",                    default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weapons", ["reference"], name: "index_weapons_on_reference", unique: true, using: :btree

end
