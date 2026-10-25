class SessionHandoff
  EXPIRES_IN = 5.minutes

  def self.issue
    SecureRandom.urlsafe_base64(32)
  end

  def self.complete(code, user)
    Rails.cache.write(key(code), user.id, expires_in: EXPIRES_IN)
  end

  def self.claim(code)
    return if code.blank?

    user_id = Rails.cache.read(key(code)) or return
    Rails.cache.delete(key(code))
    User.find_by(id: user_id)
  end

  def self.key(code) = "session_handoff/#{code}"
  private_class_method :key
end
