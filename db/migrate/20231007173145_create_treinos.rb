class CreateTreinos < ActiveRecord::Migration[7.0]
  def change
    create_table :treinos do |t|
      t.string :exercicio
      t.integer :series
      t.string :repeticoes
      t.string :carga

      t.timestamps
    end
  end
end
