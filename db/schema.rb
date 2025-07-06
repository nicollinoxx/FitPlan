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

ActiveRecord::Schema[8.0].define(version: 2025_07_06_215630) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "diets", force: :cascade do |t|
    t.string "meal"
    t.decimal "protein_g", default: "0.0"
    t.decimal "carbohydrate_g", default: "0.0"
    t.decimal "fat_g", default: "0.0"
    t.decimal "calories", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sheet_id", null: false
    t.index ["sheet_id"], name: "index_diets_on_sheet_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "message"
    t.integer "recipient_id", null: false
    t.integer "sender_id", null: false
    t.integer "sheet_id", null: false
    t.boolean "accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["sender_id"], name: "index_notifications_on_sender_id"
    t.index ["sheet_id"], name: "index_notifications_on_sheet_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sheets", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "sheet_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.boolean "copy"
    t.index ["user_id"], name: "index_sheets_on_user_id"
  end

  create_table "user_details", force: :cascade do |t|
    t.decimal "height"
    t.decimal "weight"
    t.date "birth_date"
    t.string "gender"
    t.decimal "imc"
    t.decimal "tmb"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_details_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "handle"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "workouts", force: :cascade do |t|
    t.string "exercise"
    t.integer "series"
    t.string "repetitions"
    t.string "charge"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "interval"
    t.integer "sheet_id", null: false
    t.index ["sheet_id"], name: "index_workouts_on_sheet_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "diets", "sheets"
  add_foreign_key "notifications", "sheets"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "notifications", "users", column: "sender_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "sheets", "users"
  add_foreign_key "user_details", "users"
  add_foreign_key "workouts", "sheets"
end
