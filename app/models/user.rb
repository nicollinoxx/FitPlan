class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar

  scope :search_by_name, ->(name, exclude_id) { where("LOWER(username) LIKE ? AND id != ?", "#{name.downcase}%", exclude_id) }

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end
  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_one  :user_detail, dependent: :destroy
  has_many :sessions,    dependent: :destroy
  has_many :sheets,      dependent: :destroy

  has_many :received_notifications, foreign_key: :recipient_id, dependent: :destroy, class_name: "Notification"
  has_many :sent_notifications, foreign_key: :sender_id, dependent: :destroy, class_name: "Notification"

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 12 }
  validate  :avatar_content_type, :avatar_size_validation
  validates :username, uniqueness: true

  normalizes :email, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  private

    def avatar_content_type
      if avatar.attached? && !avatar.content_type.in?(%w(image/png image/jpeg image/jpg))
        errors.add(:avatar, :error_avatar_type)
      end
    end

    def avatar_size_validation
      if avatar.attached? && avatar.byte_size > 4.megabytes
        errors.add(:avatar, :error_avatar_size)
      end
    end
end
