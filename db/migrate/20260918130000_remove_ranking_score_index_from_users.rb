class RemoveRankingScoreIndexFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_index :users, [ :ranking_score, :id ],
      order: { ranking_score: :desc },
      name: "index_users_on_ranking_score_and_id"
  end
end
