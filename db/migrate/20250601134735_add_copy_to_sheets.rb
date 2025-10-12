class AddCopyToSheets < ActiveRecord::Migration[8.0]
  def change
    add_column :sheets, :copy, :boolean, default: false, null: false
  end
end
