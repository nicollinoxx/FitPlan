class CreateFichas < ActiveRecord::Migration[7.0]
  def change
    create_table :fichas do |t|
      t.string :nome

      t.timestamps
    end
  end
end
