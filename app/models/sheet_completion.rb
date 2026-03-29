class SheetCompletion < ApplicationRecord
  belongs_to :sheet
  belongs_to :user

  validates :completed_at, presence: true

  scope :on_date, ->(date) { where(completed_at: date.all_day) }
  scope :today, -> { on_date(Date.current) }
end
