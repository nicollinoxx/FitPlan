class CreateCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :completions do |t|
      t.references :sheet, null: false, foreign_key: true
      t.references :workout, foreign_key: true
      t.references :diet, foreign_key: true
      t.datetime :completed_at, null: false

      t.timestamps
    end
  end
end
