class User < ApplicationRecord
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

  has_many :sent_sheet_requests, class_name: "SheetRequest", foreign_key: :sender_id, dependent: :destroy
  has_many :received_sheet_requests, class_name: "SheetRequest", foreign_key: :recipient_id, dependent: :destroy

  # low-level Follow records
  has_many :follower_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :following_follows, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy

  # high-level user collections
  has_many :followers, through: :follower_follows, source: :follower
  has_many :followings, through: :following_follows, source: :followed

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 6 }

  normalizes :email, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  after_save :generate_handle_unique, if: :saved_change_to_name?

  def self.search_users(query)
    return User.none unless query.present?

    normalized = normalize_search_query(query)
    pattern = search_pattern_for(normalized)

    where("name ILIKE ? OR handle ILIKE ?", pattern, pattern)
  end

  def self.normalize_search_query(query)
    I18n.transliterate(query.to_s.strip)
  end

  def self.escape_wildcards(string)
    ActiveRecord::Base.sanitize_sql_like(string.to_s)
  end

  def self.search_pattern_for(string)
    "%#{escape_wildcards(string)}%"
  end

  def follow!(followed:)
    following_follows.find_or_create_by!(followed: followed)
  end

  def unfollow!(followed:)
    following_follows.find_by(followed: followed)&.destroy!
  end

  def following?(followed)
    followings.exists?(id: followed.id)
  end

  def sheet_requests_by_filter(filter)
    if filter == "sent"
      sent_sheet_requests
    else
      received_sheet_requests
    end
  end

  private

    def generate_handle_unique
      self.update(handle: name.parameterize + "#{id}#{SecureRandom.random_number(1000)}")
    end
end
