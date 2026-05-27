class Workout < ApplicationRecord
  belongs_to :sheet
  has_one_attached :video

  has_many :completions, dependent: :destroy

  validates :exercise, :series, :repetitions, presence: true

  validate :video_size

  private

  def video_size
    return unless video.attached? && video.blob.byte_size > 16.megabytes

    errors.add(:video, :too_large, max: "16MB")
  end
end
