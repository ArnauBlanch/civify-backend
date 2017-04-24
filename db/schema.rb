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

ActiveRecord::Schema.define(version: 20170421183656) do

  create_table "confirmations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "issue_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id", "user_id"], name: "index_confirmations_on_issue_id_and_user_id", unique: true, using: :btree
  end

  create_table "issues", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.float    "latitude",             limit: 24
    t.float    "longitude",            limit: 24
    t.string   "category"
    t.string   "description"
    t.boolean  "risk"
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "issue_auth_token"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.integer  "resolved_votes"
    t.index ["issue_auth_token"], name: "index_issues_on_issue_auth_token", unique: true, using: :btree
    t.index ["user_id"], name: "index_issues_on_user_id", using: :btree
  end

  create_table "resolutions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "issue_id"
    t.index ["issue_id"], name: "index_resolutions_on_issue_id", using: :btree
    t.index ["user_id"], name: "index_resolutions_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.string   "name"
    t.string   "user_auth_token"
    t.index ["user_auth_token"], name: "index_users_on_user_auth_token", unique: true, using: :btree
  end

  add_foreign_key "issues", "users"
end
