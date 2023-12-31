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

ActiveRecord::Schema[7.0].define(version: 2023_12_31_205000) do
  create_table "diets", force: :cascade do |t|
    t.string "refeicao"
    t.string "descricao"
    t.decimal "proteina_g"
    t.decimal "carboidratos_g"
    t.decimal "gordura_g"
    t.decimal "calorias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ficha_id", null: false
    t.index ["ficha_id"], name: "index_diets_on_ficha_id"
  end

  create_table "fichas", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tipo"
    t.string "descricao"
  end

  create_table "treinos", force: :cascade do |t|
    t.string "exercicio"
    t.integer "series"
    t.string "repeticoes"
    t.string "carga"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ficha_id", null: false
    t.index ["ficha_id"], name: "index_treinos_on_ficha_id"
  end

  add_foreign_key "diets", "fichas"
  add_foreign_key "treinos", "fichas"
end
