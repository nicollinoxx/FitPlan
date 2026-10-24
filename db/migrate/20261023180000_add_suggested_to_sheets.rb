class AddSuggestedToSheets < ActiveRecord::Migration[8.1]
  def change
    add_column :sheets, :suggested, :boolean, default: false, null: false
  end
end
