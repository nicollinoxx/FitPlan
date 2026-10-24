class AddOpenRouterToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :open_router_key, :text
    add_column :users, :open_router_model, :string
  end
end
