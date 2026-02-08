class AddVisibilityToSheets < ActiveRecord::Migration[8.1]
  def change
    add_column :sheets, :visibility, :string, default: "private"
  end
end
