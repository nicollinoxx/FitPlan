class AddRankingMonthToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :ranking_month, :date
  end
end
