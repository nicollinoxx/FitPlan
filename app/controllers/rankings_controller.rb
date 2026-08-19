class RankingsController < ApplicationController
  before_action :set_user

  def global
    set_rankings_page_from User.ranked
  end

  def friends
    @has_friends = @user.friends.exists?
    set_rankings_page_from @user.friends_ranking
  end

  private

  def set_user
    @user = Current.user
  end

  def set_rankings_page_from(rankings)
    set_page_and_extract_portion_from rankings.includes(avatar_attachment: :blob)
    @offset = @page.records.offset_value.to_i
  end
end
