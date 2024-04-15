class Workout < ApplicationRecord
  has_one_attached :video

  validates :exercise, :series, :repetitions, presence: true
  validates :interval, :repetitions, length: { maximum: 15 }
end
