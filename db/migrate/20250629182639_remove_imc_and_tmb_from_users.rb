class RemoveImcAndTmbFromUsers < ActiveRecord::Migration[7.0]
  def up
    remove_column :users, :imc, :decimal
    remove_column :users, :tmb, :decimal
  end

  def down
    add_column :users, :imc, :decimal
    add_column :users, :tmb, :decimal
  end
end
