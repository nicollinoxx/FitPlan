class AddImcAndTmbToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :imc, :decimal
    add_column :users, :tmb, :decimal
  end
end
