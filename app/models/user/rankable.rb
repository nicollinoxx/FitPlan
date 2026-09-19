module User::Rankable
  extend ActiveSupport::Concern

  CONSISTENCY_WINDOW_DAYS = 30
  STREAK_CAP_DAYS         = 30

  CONSISTENCY_WEIGHT = 0.7
  STREAK_WEIGHT      = 0.3

  included do
    scope :by_current_score, -> { order(arel_table[:ranking_month].desc.nulls_last, ranking_score: :desc, id: :asc) }

    scope :current_month, -> { where(ranking_month: Date.current.beginning_of_month) }
    scope :ranked, -> { current_month.where.not(ranking_score: ..0).by_current_score }
  end

  class_methods do
    def refresh_rankings!
      find_each do |user|
        user.refresh_ranking!
      rescue StandardError => error
        Rails.error.report(error, context: { user_id: user.id }, source: "rankings")
      end
    end
  end

  def friends_ranking
    User.where(id: friends).or(User.where(id: id)).by_current_score
  end

  def position_in_ranking(ranking)
    scored = ranking.current_month
    ahead = scored.where.not(ranking_score: ..ranking_score)
    ahead.or(scored.where(ranking_score: ranking_score, id: ...id)).count + 1
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
    with_lock("FOR NO KEY UPDATE") do
      now = Time.current
      days = sheet_completions.where(completed_at: now.beginning_of_month..now).active_days
      streak = SheetCompletion.streak(today: now.to_date, days: days)
      assign_attributes(current_streak: streak, ranking_score: score_from(streak, days), ranking_month: now.to_date.beginning_of_month)
      save!(validate: false)
    end
  end

  private

  def score_from(streak, days)
    (consistency_rate(days) * CONSISTENCY_WEIGHT + streak_rate(streak) * STREAK_WEIGHT).round(2)
  end

  def consistency_rate(days)
    [days.size, CONSISTENCY_WINDOW_DAYS].min / CONSISTENCY_WINDOW_DAYS.to_f * 100
  end

  def streak_rate(streak)
    [streak, STREAK_CAP_DAYS].min / STREAK_CAP_DAYS.to_f * 100
  end
end
