class ChangeColumnTypeInDiets < ActiveRecord::Migration[7.0]
  def change
    change_column :dietas, :descricao, :string
  end
end
