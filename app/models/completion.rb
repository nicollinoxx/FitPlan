class Completion < ApplicationRecord
  include Completable

  belongs_to :sheet
  belongs_to :workout, optional: true
  belongs_to :diet,    optional: true

  before_validation -> { self.completed_at ||= Time.current }, on: :create

  validate :workout_or_diet_present

  scope :on_date, ->(date) { where(completed_at: date.all_day) }
  scope :today, -> { on_date(Date.current) }
  scope :current_round, ->(sheet) {
    last_round = sheet.sheet_completions.today.maximum(:completed_at)
    last_round ? today.where("completed_at > ?", last_round) : today
  }

  private

    def workout_or_diet_present
      errors.add(:base, :invalid) unless workout_id.present? || diet_id.present?
    end
end
