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

ActiveRecord::Schema.define(version: 5) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.string "version", null: false
    t.string "grant_type", null: false
    t.string "expired_at", null: false
    t.string "value", null: false
    t.boolean "active", default: false, null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "course_sessions", force: :cascade do |t|
    t.string "instance"
    t.string "course_name", null: false
    t.string "icon_url", default: "https://image.flaticon.com/icons/svg/149/149092.svg"
    t.string "bg_url"
    t.string "deadline"
    t.integer "period"
    t.integer "listeners_count"
    t.integer "progress", null: false
    t.datetime "started_at"
    t.boolean "can_download"
    t.boolean "success"
    t.boolean "full_access"
    t.string "application_status"
    t.string "complete_status", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_course_sessions_on_user_id"
  end

  create_table "materials", force: :cascade do |t|
    t.string "instance"
    t.string "material_name", null: false
    t.integer "category"
    t.boolean "markdown"
    t.string "source"
    t.string "type"
    t.bigint "sections_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sections_id"], name: "index_materials_on_sections_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "instance"
    t.string "part_name", null: false
    t.integer "position", null: false
    t.bigint "course_sessions_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_sessions_id"], name: "index_sections_on_course_sessions_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "external_id"
    t.string "email"
    t.string "phone"
    t.string "password"
    t.datetime "auth_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "api_tokens", "users"
  add_foreign_key "course_sessions", "users"
  add_foreign_key "materials", "sections", column: "sections_id"
  add_foreign_key "sections", "course_sessions", column: "course_sessions_id"
end
