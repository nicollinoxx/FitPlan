class AddSheetIdToDiets < ActiveRecord::Migration[7.1]
  def change
    add_reference :diets, :sheet, null: false, foreign_key: true
  end
end
