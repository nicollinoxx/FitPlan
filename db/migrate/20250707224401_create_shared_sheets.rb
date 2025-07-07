class CreateSharedSheets < ActiveRecord::Migration[8.0]
  def change
    create_table :shared_sheets do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.string :status
      t.references :sheet, null: false, foreign_key: true

      t.timestamps
    end
  end
end
