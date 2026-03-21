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

ActiveRecord::Schema[8.1].define(version: 2026_03_12_031613) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "diets", force: :cascade do |t|
    t.decimal "calories", default: "0.0"
    t.decimal "carbohydrate_g", default: "0.0"
    t.datetime "created_at", null: false
    t.decimal "fat_g", default: "0.0"
    t.string "meal"
    t.decimal "protein_g", default: "0.0"
    t.integer "sheet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["sheet_id"], name: "index_diets_on_sheet_id"
  end

  create_table "healthy_metrics", force: :cascade do |t|
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.string "gender"
    t.decimal "height"
    t.decimal "imc"
    t.decimal "tmb"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.decimal "weight"
    t.index ["user_id"], name: "index_healthy_metrics_on_user_id"
  end

  create_table "product_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.bigint "sheet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "sheet_id"], name: "index_product_items_on_product_id_and_sheet_id", unique: true
    t.index ["product_id"], name: "index_product_items_on_product_id"
    t.index ["sheet_id"], name: "index_product_items_on_sheet_id"
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "published_at"
    t.string "status", default: "draft", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["status"], name: "index_products_on_status"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sheet_imports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "imported_at"
    t.bigint "product_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_sheet_imports_on_product_id"
    t.index ["status"], name: "index_sheet_imports_on_status"
    t.index ["user_id"], name: "index_sheet_imports_on_user_id"
  end

  create_table "sheet_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "recipient_id", null: false
    t.integer "sender_id", null: false
    t.integer "sheet_id", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_sheet_requests_on_recipient_id"
    t.index ["sender_id"], name: "index_sheet_requests_on_sender_id"
    t.index ["sheet_id"], name: "index_sheet_requests_on_sheet_id"
  end

  create_table "sheets", force: :cascade do |t|
    t.boolean "copy", default: false, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "origin_type"
    t.bigint "sheet_import_id"
    t.string "sheet_type"
    t.bigint "source_sheet_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "visibility", default: "shareable", null: false
    t.index ["origin_type"], name: "index_sheets_on_origin_type"
    t.index ["sheet_import_id"], name: "index_sheets_on_sheet_import_id"
    t.index ["source_sheet_id"], name: "index_sheets_on_source_sheet_id"
    t.index ["user_id"], name: "index_sheets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "handle"
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "workouts", force: :cascade do |t|
    t.string "charge"
    t.datetime "created_at", null: false
    t.string "exercise"
    t.time "interval"
    t.string "repetitions"
    t.integer "series"
    t.integer "sheet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["sheet_id"], name: "index_workouts_on_sheet_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "diets", "sheets"
  add_foreign_key "healthy_metrics", "users"
  add_foreign_key "product_items", "products"
  add_foreign_key "product_items", "sheets"
  add_foreign_key "products", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "sheet_imports", "products"
  add_foreign_key "sheet_imports", "users"
  add_foreign_key "sheet_requests", "sheets"
  add_foreign_key "sheet_requests", "users", column: "recipient_id"
  add_foreign_key "sheet_requests", "users", column: "sender_id"
  add_foreign_key "sheets", "sheet_imports"
  add_foreign_key "sheets", "sheets", column: "source_sheet_id"
  add_foreign_key "sheets", "users"
  add_foreign_key "workouts", "sheets"
end
