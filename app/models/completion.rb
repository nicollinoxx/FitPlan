class Completion < ApplicationRecord
  include Completable

  belongs_to :sheet
  belongs_to :workout,          optional: true
  belongs_to :diet,             optional: true
  belongs_to :sheet_completion, optional: true

  before_validation -> { self.completed_at ||= Time.current }, on: :create

  validate :workout_or_diet_present

  before_create :set_remaining_series, if: -> { workout_id.present? }

  scope :on_date,       ->(date) { where(completed_at: date.all_day) }
  scope :today,         -> { on_date(Date.current) }
  scope :current_round, -> { today.where(sheet_completion_id: nil) }

  def decrement_series!
    return unless workout_id.present? && remaining_series&.positive?

    update!(remaining_series: remaining_series - 1)
  end

  def series_zero?
    workout_id.present? && remaining_series.zero?
  end

  private

    def set_remaining_series
      self.remaining_series ||= workout.series
    end

    def workout_or_diet_present
      errors.add(:base, :invalid) unless workout_id.present? || diet_id.present?
    end
end
