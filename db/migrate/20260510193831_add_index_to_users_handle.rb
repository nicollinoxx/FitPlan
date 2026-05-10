class AddIndexToUsersHandle < ActiveRecord::Migration[8.1]
  def change
    add_index :users, :handle, unique: true
  end
end
