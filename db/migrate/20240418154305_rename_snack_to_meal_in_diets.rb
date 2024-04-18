class RenameSnackToMealInDiets < ActiveRecord::Migration[7.1]
  def change
    rename_column :diets, :snack, :meal
  end
end
