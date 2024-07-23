class AddDefaultsToDiets < ActiveRecord::Migration[7.1]
  def change
    change_column_default :diets, :protein_g, from: nil, to: 0.0
    change_column_default :diets, :carbohydrate_g, from: nil, to: 0.0
    change_column_default :diets, :fat_g, from: nil, to: 0.0
    change_column_default :diets, :calories, from: nil, to: 0.0
  end
end
