class AddUniqueHandleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :handle, :string
  end
end
