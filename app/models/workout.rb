class Workout < ApplicationRecord
  include Positionable

  belongs_to :sheet
  positioned_within :sheet

  has_one_attached :video

  has_many :completions, dependent: :destroy

  validates :exercise, :series, :repetitions, presence: true

  validate :video_size

  private

  def video_size
    errors.add(:video, :error_video_size) if video.attached? && video.blob.byte_size > 16.megabytes
  end
end
