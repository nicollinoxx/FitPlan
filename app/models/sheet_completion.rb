class SheetCompletion < ApplicationRecord
  belongs_to :sheet
  belongs_to :user

  validates :completed_at, presence: true

  scope :on_date, ->(date) { where(completed_at: date.all_day) }
  scope :today, -> { on_date(Date.current) }

  def self.streak
    dates = order(completed_at: :desc).pluck(Arel.sql("DATE(completed_at)")).uniq

    streak = 0
    expected = Date.current

    dates.each do |date|
      break unless date == expected
      streak += 1
      expected -= 1.day
    end

    streak
  end

  def self.best_weekday
    result = group(Arel.sql("EXTRACT(DOW FROM completed_at)::integer")).count.max_by { |_, v| v }
    return nil unless result

    result.first
  end

  def self.weekly_progress
    this_week = where(completed_at: Date.current.beginning_of_week..Date.current.end_of_day).count
    last_week = where(completed_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week).count
    percentage = last_week > 0 ? [(this_week.to_f / last_week * 100).round, 100].min : 100

    { this_week: this_week, last_week: last_week, percentage: percentage }
  end

  def self.grouped_by(period)
    case period.to_s
    when "day"  then group_by_day(:completed_at).count
    when "week" then group_by_week(:completed_at).count
    when "year" then group_by_year(:completed_at).count
    else             group_by_month(:completed_at).count
    end
  end
end
