class ChangeMealTypeToStringsInDiets < ActiveRecord::Migration[7.1]
  def change
    change_column :diets, :meal, :string
    change_column :diets, :description, :text
  end
end
