class AddImportTrackingToSheets < ActiveRecord::Migration[8.1]
  def change
    change_table :sheets, bulk: true do |t|
      t.references :source_sheet, foreign_key: { to_table: :sheets }
      t.references :sheet_import, foreign_key: true
      t.string :origin_type
    end

    add_index :sheets, :origin_type
  end
end
