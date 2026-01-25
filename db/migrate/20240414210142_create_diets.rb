class CreateDiets < ActiveRecord::Migration[7.1]
  def change
    create_table :diets do |t|
      t.string :meal
      t.decimal :protein_g
      t.decimal :carbohydrate_g
      t.decimal :fat_g
      t.decimal :calories

      t.timestamps
    end
  end
end
