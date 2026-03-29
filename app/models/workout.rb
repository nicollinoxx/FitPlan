class Workout < ApplicationRecord
  belongs_to :sheet
  has_one_attached :video
  has_many :completions, dependent: :destroy
  has_many :completions_today, -> { today }, class_name: "Completion"

  validates :exercise, :series, :repetitions, presence: true
end
