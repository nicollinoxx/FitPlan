class AddIndexToUsersHandle < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :handle, false
    add_index :users, :handle, unique: true
  end
end
