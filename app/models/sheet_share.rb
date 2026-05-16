class SheetShare < ApplicationRecord
  belongs_to :sender,    class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :sheet_requests, dependent: :destroy

  validates :sender, :recipient, presence: true

  scope :accessible_by,     ->(user) { where(sender: user).or(where(recipient: user)) }
  scope :with_associations, -> { includes(:sender, :recipient, sheet_requests: :sheet) }

  after_create_commit :notify_recipient

  def self.create_with_requests(sender:, recipient:, sheet_ids:)
    allowed_ids = sender.sheets.with_content.where(id: sheet_ids).ids.first(5)
    create_requests!(sender, recipient, allowed_ids) unless allowed_ids.empty?
  end

  def self.create_requests!(sender, recipient, sheet_ids)
    transaction do
      share = create!(sender: sender, recipient: recipient)
      share.sheet_requests.insert_all(sheet_ids.map { { sheet_id: _1, status: "pending" } })
      share
    end
  end

  private

  def notify_recipient
    return notify_recipient_realtime if recipient.online?

    SheetShareMailer.with(share: self).new_sheet_share.deliver_later
  end

  def notify_recipient_realtime
    broadcast_replace_to("user_notifications_#{recipient_id}",
      target: "flash_container",
      partial: "shared/flash_notice/sheet_share_notice",
      locals: { share: self })
  end
end
