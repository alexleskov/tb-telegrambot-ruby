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

ActiveRecord::Schema.define(version: 19) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.integer "tb_id"
    t.integer "attempt"
    t.string "text"
    t.string "status"
    t.string "answerable_type"
    t.bigint "answerable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answerable_type", "answerable_id"], name: "index_answers_on_answerable_type_and_answerable_id"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.string "version"
    t.string "api_type"
    t.string "grant_type"
    t.string "expired_at"
    t.string "value"
    t.boolean "active", default: false, null: false
    t.bigint "auth_session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_session_id"], name: "index_api_tokens_on_auth_session_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.string "url"
    t.string "imageable_type"
    t.bigint "imageable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imageable_type", "imageable_id"], name: "index_attachments_on_imageable_type_and_imageable_id"
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

  create_table "bot_messages", force: :cascade do |t|
    t.integer "message_id", null: false
    t.integer "chat_id", null: false
    t.integer "date", null: false
    t.integer "edit_date"
    t.string "text", null: false
    t.jsonb "inline_keyboard", default: "{}"
    t.bigint "tg_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tg_account_id"], name: "index_bot_messages_on_tg_account_id"
  end

  create_table "cache_messages", force: :cascade do |t|
    t.integer "message_id"
    t.string "data"
    t.string "text"
    t.string "message_type"
    t.string "file_id"
    t.string "file_size"
    t.string "file_type"
    t.bigint "tg_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tg_account_id"], name: "index_cache_messages_on_tg_account_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "tb_user_id"
    t.string "text"
    t.string "avatar_url"
    t.string "user_name"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "course_sessions", force: :cascade do |t|
    t.string "name"
    t.string "icon_url", default: "https://image.flaticon.com/icons/svg/149/149092.svg"
    t.string "bg_url"
    t.string "application_status"
    t.string "status"
    t.string "navigation"
    t.string "scenario_mode", default: "standart_learning"
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
    t.integer "time_spent"
    t.string "name"
    t.string "content_type"
    t.string "category"
    t.string "source"
    t.string "status"
    t.boolean "editor_js", default: false
    t.boolean "markdown", default: false
    t.jsonb "content", default: "{}"
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

  create_table "quizzes", force: :cascade do |t|
    t.integer "tb_id", null: false
    t.integer "position", null: false
    t.string "name"
    t.string "status"
    t.bigint "section_id"
    t.bigint "course_session_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_session_id"], name: "index_quizzes_on_course_session_id"
    t.index ["section_id"], name: "index_quizzes_on_section_id"
    t.index ["user_id"], name: "index_quizzes_on_user_id"
  end

  create_table "scorm_packages", force: :cascade do |t|
    t.integer "tb_id", null: false
    t.integer "position", null: false
    t.string "name"
    t.string "status"
    t.string "source"
    t.bigint "section_id"
    t.bigint "course_session_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_session_id"], name: "index_scorm_packages_on_course_session_id"
    t.index ["section_id"], name: "index_scorm_packages_on_section_id"
    t.index ["user_id"], name: "index_scorm_packages_on_user_id"
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
    t.string "scenario", default: "standart_learning"
    t.bigint "tg_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tg_account_id"], name: "index_settings_on_tg_account_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "tb_id", null: false
    t.integer "position", null: false
    t.string "name"
    t.string "content"
    t.string "description"
    t.string "title"
    t.string "status"
    t.boolean "editor_js", default: false
    t.bigint "section_id"
    t.bigint "course_session_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_session_id"], name: "index_tasks_on_course_session_id"
    t.index ["section_id"], name: "index_tasks_on_section_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "tg_account_messages", force: :cascade do |t|
    t.integer "message_id"
    t.string "data"
    t.string "text"
    t.string "message_type"
    t.string "file_id"
    t.string "file_size"
    t.string "file_type"
    t.bigint "tg_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tg_account_id"], name: "index_tg_account_messages_on_tg_account_id"
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
  add_foreign_key "bot_messages", "tg_accounts"
  add_foreign_key "cache_messages", "tg_accounts"
  add_foreign_key "course_sessions", "users"
  add_foreign_key "materials", "course_sessions"
  add_foreign_key "materials", "sections"
  add_foreign_key "materials", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "quizzes", "course_sessions"
  add_foreign_key "quizzes", "sections"
  add_foreign_key "quizzes", "users"
  add_foreign_key "scorm_packages", "course_sessions"
  add_foreign_key "scorm_packages", "sections"
  add_foreign_key "scorm_packages", "users"
  add_foreign_key "sections", "course_sessions"
  add_foreign_key "sections", "users"
  add_foreign_key "settings", "tg_accounts"
  add_foreign_key "tasks", "course_sessions"
  add_foreign_key "tasks", "sections"
  add_foreign_key "tasks", "users"
  add_foreign_key "tg_account_messages", "tg_accounts"
end
