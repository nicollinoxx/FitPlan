class AddCopyToSheets < ActiveRecord::Migration[8.0]
  def change
    add_column :sheets, :copy, :boolean
  end
end
