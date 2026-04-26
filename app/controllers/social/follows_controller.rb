class Social::FollowsController < ApplicationController
  def followers
    @follower_follows = Current.user.follower_follows.includes(:follower).order(created_at: :desc)
    @following_ids    = Current.user.following_ids.to_set

    Current.user.mark_followers_as_seen!
  end

  def followings
    @followings = Current.user.followings.order(:name)
  end
end
