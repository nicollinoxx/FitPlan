class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true, uniqueness: { scope: :followed_id }
  validates :followed_id, presence: true
  validate  :cannot_follow_self, if: -> { follower_id.present? && followed_id.present? }

  after_create_commit :broadcast_follow_toast

  private

  def broadcast_follow_toast
    broadcast_replace_to("follow_notifications_#{followed.id}",
      target: "flash_container",
      partial: "layouts/flash_notice/follow_notice",
      locals: { follower: follower })
  end

  def cannot_follow_self
    errors.add(:follower_id, "can't follow yourself") if follower_id == followed_id
  end
end
