class CreateDietas < ActiveRecord::Migration[7.0]
  def change
    create_table :dietas do |t|
      t.string :refeicao
      t.string :descricao
      t.decimal :proteina_g
      t.decimal :carboidratos_g
      t.decimal :gordura_g
      t.decimal :calorias

      t.timestamps
    end
  end
end
