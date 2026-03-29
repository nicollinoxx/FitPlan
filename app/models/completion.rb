class Completion < ApplicationRecord
  include Completable

  belongs_to :user
  belongs_to :sheet
  belongs_to :workout, optional: true
  belongs_to :diet, optional: true

  validates :completed_at, presence: true
  validate :workout_or_diet_present

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

  private

    def workout_or_diet_present
      errors.add(:base, :invalid) unless workout_id.present? || diet_id.present?
    end
end
