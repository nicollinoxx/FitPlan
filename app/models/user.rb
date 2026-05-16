class User < ApplicationRecord
  include Normalizable
  include User::Followable
  include User::Shareable

  has_secure_password
  has_one_attached :avatar

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end
  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_one  :healthy_metric,     dependent: :destroy
  has_many :sessions,           dependent: :destroy
  has_many :sheets,             dependent: :destroy
  has_many :sheet_completions

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 6 }
  validates :handle, presence: true, uniqueness: true, length: { minimum: 3 },
                     format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }, on: :update

  normalizes :email, :handle, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  before_create :generate_handle_unique

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  def self.search_users(query)
    return none unless query.present?

    where("name ILIKE :search OR handle ILIKE :search", search: "%#{sanitize_search(query)}%")
  end

  def to_param
    handle
  end

  def online?
    Rails.cache.exist?("user_online:#{id}")
  end

  private

  def generate_handle_unique
    loop do
      self.handle = "#{name.parameterize}-#{SecureRandom.hex(4)}"
      break unless User.exists?(handle: handle)
    end
  end
end
