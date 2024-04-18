class ChangeMealTypeInDiets < ActiveRecord::Migration[7.1]
  def change
    change_column :diets, :meal, :text
  end
end
