class CreateProductItems < ActiveRecord::Migration[8.1]
  def change
    create_table :product_items do |t|
      t.references :product, null: false, foreign_key: true
      t.references :sheet, null: false, foreign_key: true

      t.timestamps
    end

    add_index :product_items, [ :product_id, :sheet_id ], unique: true
  end
end
