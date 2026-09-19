class RefreshRankingsJob < ApplicationJob
  queue_as :default

  def perform
    User.refresh_rankings!
  end
end
