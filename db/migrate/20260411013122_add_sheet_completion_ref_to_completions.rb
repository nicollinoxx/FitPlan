class AddSheetCompletionRefToCompletions < ActiveRecord::Migration[8.1]
  def change
    add_reference :completions, :sheet_completion, null: true, foreign_key: true
  end
end
