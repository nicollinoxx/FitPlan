class AddFichaidToTreinos < ActiveRecord::Migration[7.0]
  def change
    add_reference :treinos, :ficha, null: false, foreign_key: true
  end
end
