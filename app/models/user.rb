class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end
  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_one  :user_detail, dependent: :destroy
  has_many :sessions,    dependent: :destroy
  has_many :sheets,      dependent: :destroy

  has_many :sent_sheet_requests, class_name: "SheetRequest", foreign_key: :sender_id, dependent: :destroy
  has_many :received_sheet_requests, class_name: "SheetRequest", foreign_key: :recipient_id, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 12 }
  validates :handle, uniqueness: true, allow_nil: true
  validates :name, presence: true

  normalizes :email, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  before_create :generate_handle_unique

  private

    def generate_handle_unique
      self.handle ||= "user_#{id || User.maximum(:id).to_i + 1}"
    end
end
