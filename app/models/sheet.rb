class Sheet < ApplicationRecord
  has_many :workouts, dependent: :destroy

  validates :name, :sheet_type, presence: true
  validates :sheet_type, inclusion: { in: %w(workout diet) }
end
