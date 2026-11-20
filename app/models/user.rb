class User < ApplicationRecord
  include Normalizable
  include Followable
  include Shareable
  include Rankable
  include Omniauthable
  include OpenRouter::Connectable

  LINK_TLDS = %w[
    com net org info biz pro tech xyz top site online website space fun shop store click link live club vip
    app dev io ai me co cc ly gg tv ws icu sbs cfd cyou bond buzz lol rest quest monster win bid loan work
    life today world email digital agency cloud tk ml ga cf gq pw su ru cn br us uk de fr es it pt in mx ar
  ].freeze

  LINK_PATTERN = %r{
    [a-z][a-z0-9+.-]*://
    | \bwww\.
    | \b[\p{L}\d-]+\.(?:#{LINK_TLDS.join("|")})\b
  }ix

  has_secure_password
  has_one_attached :avatar

  generates_token_for :email_verification, expires_in: 2.days do
    [ email, unconfirmed_email ]
  end
  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_one  :healthy_metric,     dependent: :destroy
  has_many :sessions,           dependent: :destroy
  has_many :sheets,             dependent: :destroy
  has_many :sheet_completions

  validate :avatar_size, if: -> { attachment_changes["avatar"] }
  validate :name_cannot_contain_links, if: :name_changed?

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :unconfirmed_email, allow_nil: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 6 }
  validates :handle, presence: true, uniqueness: true, length: { minimum: 3 },
                     format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }, on: :update, if: :handle_changed?

  validates :locale, allow_nil: true, inclusion: { in: I18n.available_locales.map(&:to_s) }

  normalizes :email, :unconfirmed_email, :handle, with: -> { _1.strip.downcase }

  before_create :generate_handle_unique

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  def self.without_links(text)
    text.to_s.split.reject { |word| word.match?(LINK_PATTERN) }.join(" ")
  end

  def self.search_users(query)
    return none unless query.present?

    where("name ILIKE :search OR handle ILIKE :search", search: "%#{sanitize_search(query)}%")
  end

  def to_param
    handle
  end

  def email_to_verify
    unconfirmed_email || email
  end

  def email_to_verify_taken?
    User.where.not(id:).exists?(email: email_to_verify)
  end

  def verify_email
    update email: email_to_verify, unconfirmed_email: nil, verified: true
  end

  def online?
    Rails.cache.exist?("user_online:#{id}")
  end

  def name_without_links
    User.without_links(name).presence || handle
  end

  private

  def name_cannot_contain_links
    errors.add(:name, :contains_link) if name.to_s.match?(LINK_PATTERN)
  end

  def avatar_size
    errors.add(:avatar, :error_avatar_size) if avatar.attached? && avatar.blob.byte_size > 4.megabytes
  end

  def generate_handle_unique
    loop do
      self.handle = "#{name.to_s.parameterize.presence || 'user'}-#{SecureRandom.hex(4)}"
      break unless User.exists?(handle: handle)
    end
  end
end
