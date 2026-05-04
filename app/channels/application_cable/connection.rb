module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = authenticate
      Rails.cache.write("user_online:#{current_user.id}", true, expires_in: 10.minutes)
    end

    private

    def authenticate
      session = Session.find_by(id: cookies.signed[:session_token])
      session&.user || reject_unauthorized_connection
    end
  end
end
