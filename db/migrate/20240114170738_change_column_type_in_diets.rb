class ChangeColumnTypeInDiets < ActiveRecord::Migration[7.0]
  def change
    change_column :diets, :descricao, :string
  end
end
