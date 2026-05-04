class PresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "presence_#{current_user.id}"
  end

  def heartbeat
    Rails.cache.write("user_online:#{current_user.id}", true, expires_in: 10.minutes)
  end
end
