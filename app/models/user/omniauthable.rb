require "open-uri"

module User::Omniauthable
  extend ActiveSupport::Concern

  class_methods do
    def from_omniauth(auth)
      return if auth.blank?

      user = find_by(provider: auth.provider, uid: auth.uid) || find_or_initialize_by(email: auth.info.email)

      user.assign_attributes(signup_attributes(auth)) if user.new_record?
      user.update!(provider: auth.provider, uid: auth.uid)

      user.attach_avatar_from(auth.info.image)
      user
    end

    private

      def signup_attributes(auth)
        { name: auth.info.name, password: SecureRandom.hex(16), verified: true }
      end
  end

  def attach_avatar_from(url)
    return if avatar.attached? || url.blank?

    file = URI.open(url)
    avatar.attach(io: file, filename: "avatar", content_type: file.content_type)
  end
end
