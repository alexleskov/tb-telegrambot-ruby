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

ActiveRecord::Schema.define(version: 10) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.string "version"
    t.string "grant_type"
    t.string "expired_at"
    t.string "value"
    t.boolean "active", default: false, null: false
    t.bigint "auth_session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_session_id"], name: "index_api_tokens_on_auth_session_id"
  end

  create_table "auth_sessions", force: :cascade do |t|
    t.datetime "auth_at"
    t.boolean "active", default: false, null: false
    t.bigint "user_id"
    t.bigint "tg_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "api_token_id"
    t.index ["api_token_id"], name: "index_auth_sessions_on_api_token_id"
    t.index ["tg_account_id"], name: "index_auth_sessions_on_tg_account_id"
    t.index ["user_id"], name: "index_auth_sessions_on_user_id"
  end

  create_table "course_sessions", force: :cascade do |t|
    t.string "name"
    t.string "icon_url", default: "https://image.flaticon.com/icons/svg/149/149092.svg"
    t.string "bg_url"
    t.string "application_status"
    t.string "complete_status"
    t.string "navigation"
    t.integer "tb_id", null: false
    t.integer "deadline"
    t.integer "listeners_count"
    t.integer "progress"
    t.integer "started_at"
    t.integer "changed_at"
    t.boolean "can_download"
    t.boolean "success"
    t.boolean "full_access"
    t.boolean "has_certificate"
    t.float "rating"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_course_sessions_on_user_id"
  end

  create_table "materials", force: :cascade do |t|
    t.integer "tb_id", null: false
    t.integer "position", null: false
    t.string "name"
    t.string "content_type"
    t.string "category"
    t.bigint "section_id"
    t.bigint "course_session_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_session_id"], name: "index_materials_on_course_session_id"
    t.index ["section_id"], name: "index_materials_on_section_id"
    t.index ["user_id"], name: "index_materials_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "active_courses_count", default: 0
    t.integer "average_score_percent", default: 0
    t.integer "archived_courses_count", default: 0
    t.integer "total_time_spent", default: 0
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "sections", force: :cascade do |t|
    t.boolean "is_publish"
    t.boolean "is_available"
    t.string "name"
    t.integer "opened_at"
    t.integer "position", null: false
    t.bigint "course_session_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_session_id"], name: "index_sections_on_course_session_id"
    t.index ["user_id"], name: "index_sections_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "localization", default: "ru"
    t.string "scenario", default: "StandartLearning"
    t.bigint "tg_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tg_account_id"], name: "index_settings_on_tg_account_id"
  end

  create_table "tg_accounts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer "tb_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.string "password"
    t.string "avatar_url", default: "https://image.flaticon.com/icons/png/512/149/149071.png"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "api_tokens", "auth_sessions"
  add_foreign_key "auth_sessions", "api_tokens"
  add_foreign_key "auth_sessions", "tg_accounts"
  add_foreign_key "auth_sessions", "users"
  add_foreign_key "course_sessions", "users"
  add_foreign_key "materials", "course_sessions"
  add_foreign_key "materials", "sections"
  add_foreign_key "materials", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "sections", "course_sessions"
  add_foreign_key "sections", "users"
  add_foreign_key "settings", "tg_accounts"
end
