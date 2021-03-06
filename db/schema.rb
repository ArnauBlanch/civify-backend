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

ActiveRecord::Schema.define(version: 20170609001722) do

  create_table "achievement_progresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "achievement_id"
    t.integer  "progress",       default: 0
    t.boolean  "completed",      default: false
    t.boolean  "claimed",        default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["achievement_id"], name: "index_achievement_progresses_on_achievement_id", using: :btree
    t.index ["user_id"], name: "index_achievement_progresses_on_user_id", using: :btree
  end

  create_table "achievements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "number"
    t.integer  "kind"
    t.integer  "coins"
    t.integer  "xp"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "achievement_token"
    t.boolean  "enabled",           default: true
    t.index ["achievement_token"], name: "index_achievements_on_achievement_token", unique: true, using: :btree
  end

  create_table "awards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "price"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "offered_by"
    t.string   "award_auth_token"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.boolean  "visible",              default: true
    t.index ["award_auth_token"], name: "index_awards_on_award_auth_token", unique: true, using: :btree
    t.index ["offered_by"], name: "index_awards_on_offered_by", using: :btree
  end

  create_table "badges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "badgeable_type"
    t.integer  "badgeable_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.index ["badgeable_type", "badgeable_id"], name: "index_badges_on_badgeable_type_and_badgeable_id", using: :btree
  end

  create_table "badges_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "badge_id"
    t.integer "user_id"
    t.index ["badge_id"], name: "index_badges_users_on_badge_id", using: :btree
    t.index ["user_id"], name: "index_badges_users_on_user_id", using: :btree
  end

  create_table "confirmations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "issue_id"
    t.integer  "user_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "confirmed",  default: true
    t.index ["issue_id", "user_id"], name: "index_confirmations_on_issue_id_and_user_id", unique: true, using: :btree
    t.index ["issue_id"], name: "index_confirmations_on_issue_id", using: :btree
    t.index ["user_id"], name: "index_confirmations_on_user_id", using: :btree
  end

  create_table "event_progresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "completed",  default: false
    t.boolean  "claimed",    default: false
    t.integer  "progress",   default: 0
    t.index ["event_id", "user_id"], name: "index_event_progresses_on_event_id_and_user_id", unique: true, using: :btree
  end

  create_table "events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "number"
    t.integer  "coins"
    t.integer  "xp"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "kind"
    t.string   "event_token"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "enabled",            default: true
    t.index ["event_token"], name: "index_events_on_event_token", unique: true, using: :btree
  end

  create_table "exchanges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "award_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "used",                default: false
    t.string   "exchange_auth_token"
    t.index ["award_id", "user_id"], name: "index_exchanges_on_award_id_and_user_id", unique: true, using: :btree
    t.index ["award_id"], name: "index_exchanges_on_award_id", using: :btree
    t.index ["exchange_auth_token"], name: "index_exchanges_on_exchange_auth_token", unique: true, using: :btree
    t.index ["user_id"], name: "index_exchanges_on_user_id", using: :btree
  end

  create_table "issues", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.text     "title",                limit: 65535
    t.float    "latitude",             limit: 24
    t.float    "longitude",            limit: 24
    t.string   "category"
    t.text     "description",          limit: 65535
    t.boolean  "risk"
    t.integer  "user_id"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "issue_auth_token"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.integer  "resolved_votes",                     default: 0
    t.boolean  "resolved",                           default: false
    t.index ["issue_auth_token"], name: "index_issues_on_issue_auth_token", unique: true, using: :btree
    t.index ["user_id"], name: "index_issues_on_user_id", using: :btree
  end

  create_table "reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "issue_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "marked_reported", default: true
    t.index ["issue_id", "user_id"], name: "index_reports_on_issue_id_and_user_id", unique: true, using: :btree
    t.index ["issue_id"], name: "index_reports_on_issue_id", using: :btree
    t.index ["user_id"], name: "index_reports_on_user_id", using: :btree
  end

  create_table "resolutions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "issue_id"
    t.boolean  "marked_resolved", default: true
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["issue_id"], name: "index_resolutions_on_issue_id", using: :btree
    t.index ["user_id"], name: "index_resolutions_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "password_digest"
    t.string   "user_auth_token"
    t.integer  "coins",           default: 0
    t.integer  "kind",            default: 0
    t.bigint   "xp",              default: 0
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.integer  "profile_icon",    default: 2
    t.index ["user_auth_token"], name: "index_users_on_user_auth_token", unique: true, using: :btree
  end

  add_foreign_key "awards", "users", column: "offered_by"
  add_foreign_key "issues", "users"
end
