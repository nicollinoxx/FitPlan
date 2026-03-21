class CreateSheetImports < ActiveRecord::Migration[8.1]
  def change
    create_table :sheet_imports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.datetime :imported_at

      t.timestamps
    end

    add_index :sheet_imports, :status
  end
end
