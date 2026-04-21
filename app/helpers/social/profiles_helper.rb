module Social::ProfilesHelper
  def follow_toggle(profile)
    return if Current.user == profile

    unless Current.user.following?(profile)
      button_to t('follow'), follow_social_profile_path(profile), method: :post, class: "btn btn-success flex-shrink-0"
    else
      button_to t('unfollow'), unfollow_social_profile_path(profile), method: :delete, class: "btn btn-danger flex-shrink-0"
    end
  end
end
