module Social::ProfilesHelper
  def follow_toggle(profile)
    return if Current.user == profile

    if Current.user.following?(profile)
      button_to t('unfollow'), unfollow_social_profile_path(profile), method: :delete, class: "btn btn-secondary flex-shrink-0"
    elsif profile.following?(Current.user)
      button_to t('follow_back'), follow_social_profile_path(profile), method: :post, class: "btn btn-success flex-shrink-0"
    else
      button_to t('follow'), follow_social_profile_path(profile), method: :post, class: "btn btn-success flex-shrink-0"
    end
  end

  def profile_action_link(profile)
    if profile == Current.user
      identity_profile_path
    else
      social_profile_path(profile, query: params[:query])
    end
  end

  def back_or_profiles_path
    request.referer&.start_with?(root_url) ? request.referer : social_profiles_path
  end
end
