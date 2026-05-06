module User::Followable
  extend ActiveSupport::Concern

  included do
    # low-level Follow records
    has_many :follower_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
    has_many :following_follows, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy

    # high-level user collections
    has_many :followers, through: :follower_follows, source: :follower
    has_many :followings, through: :following_follows, source: :followed
  end

  def follow!(followed:)
    following_follows.find_or_create_by!(followed: followed)
  end

  def unfollow!(followed:)
    following_follows.find_by(followed: followed)&.destroy!
  end

  def following?(followed)
    followings.exists?(id: followed.id)
  end

  def mark_followers_as_seen!
    follower_follows.where(seen_at: nil).update_all(seen_at: Time.current)
  end

  def unseen_followers?
    follower_follows.where(seen_at: nil).exists?
  end
end
