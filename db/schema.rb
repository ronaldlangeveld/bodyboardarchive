# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_03_063229) do
  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", limit: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
  end

  create_table "profile_countries", force: :cascade do |t|
    t.integer "profile_id", null: false
    t.integer "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_profile_countries_on_country_id"
    t.index ["profile_id", "country_id"], name: "index_profile_countries_on_profile_id_and_country_id", unique: true
    t.index ["profile_id"], name: "index_profile_countries_on_profile_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "username", null: false
    t.text "bio"
    t.date "date_of_birth"
    t.boolean "is_rider", default: false
    t.boolean "is_photographer", default: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "sixty_forty_import", default: false
    t.string "import_name"
    t.datetime "imported_at"
    t.string "import_location"
    t.index ["import_location"], name: "index_profiles_on_import_location"
    t.index ["user_id"], name: "index_profiles_on_user_id"
    t.index ["username"], name: "index_profiles_on_username", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "profile_countries", "countries"
  add_foreign_key "profile_countries", "profiles"
  add_foreign_key "profiles", "users"
end
