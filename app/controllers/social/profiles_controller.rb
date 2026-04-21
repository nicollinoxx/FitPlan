class Social::ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :follow, :unfollow]

  def index
    @profiles = User.search_users(params[:query])
  end

  def show
  end

  def follow
    Current.user.follow!(followed: @profile)
    refresh_or_redirect_to social_profile_path(@profile), notice: I18n.t('notice.social.profiles.follow', name: @profile.name)
  end

  def unfollow
    Current.user.unfollow!(followed: @profile)
    refresh_or_redirect_to social_profile_path(@profile), notice: I18n.t('notice.social.profiles.unfollow', name: @profile.name)
  end

  private

  def set_profile
    @profile = User.find(params.expect(:id))
  end
end
