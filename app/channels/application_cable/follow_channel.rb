class ApplicationCable::FollowChannel < ApplicationCable::Channel
  def subscribed
    stream_from Current.user
  end
end
