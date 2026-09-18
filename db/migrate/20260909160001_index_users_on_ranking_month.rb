class IndexUsersOnRankingMonth < ActiveRecord::Migration[8.1]
  def change
    add_index :users, [ :ranking_month, :ranking_score, :id ],
      order: { ranking_score: :desc },
      name: "index_users_on_ranking_month_and_ranking_score_and_id"
  end
end
