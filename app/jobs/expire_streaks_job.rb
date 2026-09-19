class ExpireStreaksJob < ApplicationJob
  queue_as :default

  def perform
    User.expire_streaks!
  end
end
