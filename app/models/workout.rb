class Workout < ApplicationRecord
  validates :exercise, :series, :repetitions, presence: true
  validates :interval, :repetitions, length: { maximum: 15 }
end
