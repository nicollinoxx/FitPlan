class Social::ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :follow, :unfollow, :followers, :followings]
  after_action :mark_followers_as_seen, only: :followers

  def index
    @profiles = User.search_users(params[:query]).includes(avatar_attachment: :blob)
  end

  def show
    @followers_count  = @profile.followers.count
    @followings_count = @profile.followings.count
  end

  def follow
    Current.user.follow!(followed: @profile)
    refresh_or_redirect_to social_profile_path(@profile), notice: I18n.t('notice.social.profiles.follow', name: @profile.name)
  end

  def unfollow
    Current.user.unfollow!(followed: @profile)
    refresh_or_redirect_to social_profile_path(@profile), notice: I18n.t('notice.social.profiles.unfollow', name: @profile.name)
  end

  def followers
    @followers = @profile.followers.order(created_at: :desc).includes(avatar_attachment: :blob)
  end

  def followings
    @followings = @profile.followings.order(:name).includes(avatar_attachment: :blob)
  end

  private

  def set_profile
    @profile = User.find(params.expect(:id))
  end

  def mark_followers_as_seen
    Current.user.mark_followers_as_seen! if @profile == Current.user && Current.user.unseen_followers?
  end
end
