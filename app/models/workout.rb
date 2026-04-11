class Workout < ApplicationRecord
  belongs_to :sheet
  has_one_attached :video

  has_many :completions, dependent: :destroy

  validates :exercise, :series, :repetitions, presence: true

  def current_round_completion
    completions.current_round.first
  end
end
