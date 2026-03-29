class SheetCompletion < ApplicationRecord
  belongs_to :sheet
  belongs_to :user

  validates :completed_at, presence: true

  scope :on_date, ->(date) { where(completed_at: date.all_day) }
  scope :today, -> { on_date(Date.current) }

  def self.grouped_by(period)
    case period.to_s
    when "day"  then group_by_day(:completed_at).count
    when "week" then group_by_week(:completed_at).count
    when "year" then group_by_year(:completed_at).count
    else             group_by_month(:completed_at).count
    end
  end
end
