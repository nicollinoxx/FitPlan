module User::Rankable
  extend ActiveSupport::Concern

  CONSISTENCY_WINDOW_DAYS = 30
  STREAK_CAP_DAYS         = 30

  CONSISTENCY_WEIGHT = 0.7
  STREAK_WEIGHT      = 0.3

  included do
    scope :by_score, -> {
      score = Arel::Nodes::Case.new(arel_table[:ranking_month]).when(Date.current.beginning_of_month)
        .then(arel_table[:ranking_score]).else(0)
      order(score.desc, id: :asc)
    }
    scope :ranked, -> { where(ranking_month: Date.current.beginning_of_month).where.not(ranking_score: ..0).by_score }
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
    rankings = User.ranked
    higher_scores = rankings.where.not(ranking_score: ..ranking_score)
    higher_scores.or(rankings.where(ranking_score: ranking_score, id: ...id)).count + 1
  end

  def ranking_score
    ranking_month == Date.current.beginning_of_month ? super : 0.to_d
  end

  def current_streak
    ranking_month == Date.current.beginning_of_month ? super : 0
  end

  def ranked?
    ranking_score.positive?
  end

  def refresh_ranking!
    with_lock do
      now = Time.current
      completions = sheet_completions.where(completed_at: now.beginning_of_month..now)
      streak = completions.streak(today: now.to_date)
      update!(current_streak: streak, ranking_score: score_from(streak, completions, now), ranking_month: now.to_date.beginning_of_month)
    end
  end

  private

  def score_from(streak, completions, now)
    (consistency_rate(completions, now) * CONSISTENCY_WEIGHT + streak_rate(streak) * STREAK_WEIGHT).round(2)
  end

  def consistency_rate(completions, now)
    active_days = completions.active_days_since(now - CONSISTENCY_WINDOW_DAYS.days)
    active_days / CONSISTENCY_WINDOW_DAYS.to_f * 100
  end

  def streak_rate(streak)
    [streak, STREAK_CAP_DAYS].min / STREAK_CAP_DAYS.to_f * 100
  end
end
