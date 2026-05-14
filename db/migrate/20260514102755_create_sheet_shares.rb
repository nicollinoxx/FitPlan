class CreateSheetShares < ActiveRecord::Migration[8.0]
  def change
    create_table :sheet_shares do |t|
      t.references :sender,    null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    remove_reference :sheet_requests, :sender,    foreign_key: { to_table: :users }
    remove_reference :sheet_requests, :recipient, foreign_key: { to_table: :users }

    add_reference :sheet_requests, :sheet_share, null: false, foreign_key: true
  end
end
