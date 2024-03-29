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

ActiveRecord::Schema.define(version: 20151226081516) do

  create_table "folders", force: :cascade do |t|
    t.string   "name",       limit: 255, default: "Folder", null: false
    t.integer  "user_id",    limit: 4
    t.integer  "parent_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: :cascade do |t|
    t.string   "name",         limit: 255,                null: false
    t.string   "content_type", limit: 32
    t.string   "type",         limit: 8
    t.string   "md5",          limit: 32
    t.integer  "size",         limit: 4,   default: 0,    null: false
    t.integer  "user_id",      limit: 4
    t.integer  "parent_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",     limit: 4,   default: 0,    null: false
    t.integer  "file_id",      limit: 4
    t.boolean  "delta",                    default: true, null: false
  end

  add_index "items", ["parent_id"], name: "index_items_on_parent_id", using: :btree
  add_index "items", ["user_id"], name: "index_items_on_user_id", using: :btree

  create_table "uploads", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "content_type", limit: 32
    t.string   "md5",          limit: 32
    t.integer  "size",         limit: 4,   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "folder_id",    limit: 4
  end

  add_index "uploads", ["folder_id"], name: "index_uploads_on_folder_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
