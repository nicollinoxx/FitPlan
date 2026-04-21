class Social::ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :follow, :unfollow]

  def index
    @profiles = User.search_by(params[:query])
  end

  def show
  end

  def follow
    Current.user.follow!(@profile)
    refresh_or_redirect_to social_profile_path(@profile), notice: "You are now following #{@profile.name}"
  end

  def unfollow
    Current.user.unfollow!(@profile)
    refresh_or_redirect_to social_profile_path(@profile), notice: "You are no longer following #{@profile.name}"
  end

  private

  def set_profile
    @profile = User.find(params.expect(:id))
  end
end
