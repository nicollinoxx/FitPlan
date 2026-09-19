class AddConsistencyScoreToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :consistency_score, :decimal, precision: 5, scale: 2, null: false, default: 0
  end
end
