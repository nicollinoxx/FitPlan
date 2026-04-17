class AddUserCompletedAtIndexToSheetCompletions < ActiveRecord::Migration[8.1]
  def change
    add_index :sheet_completions, [:user_id, :completed_at]
    remove_index :sheet_completions, :user_id
  end
end
