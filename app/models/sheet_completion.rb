class SheetCompletion < ApplicationRecord
  belongs_to :sheet
  belongs_to :user

  has_many :completions, dependent: :destroy

  validates :completed_at, presence: true

  before_validation -> { self.completed_at ||= Time.current }, on: :create

  scope :on_date, ->(date) { where(completed_at: date.all_day) }
  scope :today, -> { on_date(Date.current) }

  def self.streak
    dates = where(completed_at: 1.year.ago..).pluck(Arel.sql("DATE(completed_at)")).uniq.sort.reverse
    dates.each_with_index.take_while { |date, index| date == Date.current - index }.size
  end

  def self.best_weekday
    group(Arel.sql("EXTRACT(DOW FROM completed_at)::integer")).count.max_by { |_, value| value }&.first
  end

  def self.weekly_progress
    this_week  = where(completed_at: Date.current.all_week).count
    last_week  = where(completed_at: 1.week.ago.all_week).count
    percentage = weekly_progress_percentage(this_week, last_week)

    { this_week:, last_week:, percentage: }
  end

  def self.weekly_progress_percentage(this_week, last_week)
    last_week.zero? ? 100 : [(this_week * 100.0 / last_week).round, 100].min
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
