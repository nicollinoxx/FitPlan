class Workout < ApplicationRecord
  belongs_to :sheet
  has_one_attached :video

  validates :exercise, :series, :repetitions, presence: true
  validates :interval, :repetitions, length: { maximum: 15 }
  validate  :video_content_type, :video_size_validation

  private

    def video_content_type
     if video.attached? && !video.content_type.in?(%w(video/mp4 video/mpeg video/quicktime))
       errors.add(:video, :error_video_type)
     end
    end

    def video_size_validation
      if video.attached? && video.byte_size > 16.megabytes
        errors.add(:video, :error_video_size)
      end
    end
end
