class AddRankingToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :ranking_score,  :decimal, precision: 5, scale: 2, default: 0.0, null: false
    add_column :users, :current_streak, :integer, default: 0, null: false

    add_index :users, [:ranking_score, :id], order: { ranking_score: :desc, id: :asc }

    reversible do |direction|
      direction.up { User.refresh_rankings! }
    end
  end
end
