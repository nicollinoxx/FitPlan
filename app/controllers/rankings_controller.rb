class RankingsController < ApplicationController
  before_action :set_user

  def global
    set_rankings_page_from User.ranked
  end

  def friends
    set_rankings_page_from @user.friends_ranking
  end

  private

  def set_user
    @user = Current.user
  end

  def set_rankings_page_from(rankings)
    @position = @user.position_in_ranking(rankings)

    set_page_and_extract_portion_from rankings.includes(avatar_attachment: :blob)
    @offset = @page.records.offset_value.to_i
  end
end
