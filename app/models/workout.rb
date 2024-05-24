class Workout < ApplicationRecord
  belongs_to :sheet
  has_one_attached :video

  validates :exercise, :series, :repetitions, presence: true
  validates :interval, :repetitions, length: { maximum: 15 }, allow_blank: true
  validate :video_content_type

   private

   def video_content_type
     if video.attached? && !video.content_type.in?(%w(video/mp4 video/mpeg video/quicktime))
       errors.add(:video, 'must be a file (MP4, MPEG, QuickTime)')
     end
   end
end
