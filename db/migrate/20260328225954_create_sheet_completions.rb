class CreateSheetCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :sheet_completions do |t|
      t.references :sheet, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :completed_at, null: false

      t.timestamps
    end
  end
end
