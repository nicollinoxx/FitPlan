module User::Rankable
  extend ActiveSupport::Concern

  CONSISTENCY_WINDOW_DAYS = 30
  STREAK_CAP_DAYS         = 30

  CONSISTENCY_WEIGHT = 0.7
  STREAK_WEIGHT      = 0.3

  included do
    scope :by_score, -> { order(ranking_score: :desc, id: :asc) }
    scope :ranked,   -> { where("ranking_score > 0").by_score }
  end

  class_methods do
    def refresh_rankings!
      find_each(&:refresh_ranking!)
    end
  end

  def friends_ranking
    User.where(id: friends).or(User.where(id: id)).by_score
  end

  def ranking_position
    User.where("ranking_score > ?", ranking_score).count + 1
  end

  def ranked?
    ranking_score.positive?
  end

  def refresh_ranking!
    streak = sheet_completions.streak
    update!(current_streak: streak, ranking_score: score_from(streak))
  end

  private

  def score_from(streak)
    (consistency_rate * CONSISTENCY_WEIGHT + streak_rate(streak) * STREAK_WEIGHT).round(2)
  end

  def consistency_rate
    active_days = sheet_completions.active_days_since(CONSISTENCY_WINDOW_DAYS.days.ago)
    active_days / CONSISTENCY_WINDOW_DAYS.to_f * 100
  end

  def streak_rate(streak)
    [streak, STREAK_CAP_DAYS].min / STREAK_CAP_DAYS.to_f * 100
  end
end
