class AddSheetToCompletions < ActiveRecord::Migration[8.1]
  def change
    add_reference :completions, :sheet, foreign_key: true
  end
end
