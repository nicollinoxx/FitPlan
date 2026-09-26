module Social::ProfilesHelper
  def follow_toggle(profile)
    return if Current.user == profile

    if Current.user.following?(profile)
      button_to t('unfollow'), unfollow_social_profile_path(profile), method: :delete, class: "btn btn-secondary flex-shrink-0", id: follow_toggle_id('unfollow'), data: follow_toggle_bridge('unfollow')
    elsif profile.following?(Current.user)
      button_to t('follow_back'), follow_social_profile_path(profile), method: :post, class: "btn btn-success flex-shrink-0", id: follow_toggle_id('follow_back'), data: follow_toggle_bridge('follow_back')
    else
      button_to t('follow'), follow_social_profile_path(profile), method: :post, class: "btn btn-success flex-shrink-0", id: follow_toggle_id('follow'), data: follow_toggle_bridge('follow')
    end
  end

  def profile_action_link(profile)
    if profile == Current.user
      identity_profile_path
    else
      social_profile_path(profile, query: params[:query])
    end
  end

  private

  def follow_toggle_bridge(translation_key)
    { controller: "bridge--nav-button", bridge_title: t(translation_key) }
  end

  def follow_toggle_id(translation_key)
    "follow_toggle_#{translation_key}"
  end
end
