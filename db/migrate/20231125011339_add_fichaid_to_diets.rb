class AddFichaidToDiets < ActiveRecord::Migration[7.0]
  def change
    add_reference :diets, :ficha, null: false, foreign_key: true
  end
end
