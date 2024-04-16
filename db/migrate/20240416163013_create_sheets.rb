class CreateSheets < ActiveRecord::Migration[7.1]
  def change
    create_table :sheets do |t|
      t.string :name
      t.text :description
      t.string :sheet_type

      t.timestamps
    end
  end
end
