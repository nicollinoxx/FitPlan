class SheetShare < ApplicationRecord
  belongs_to :sender,    class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :sheet_requests, dependent: :destroy

  validates :sender, :recipient, presence: true

  scope :accessible_by,     ->(user) { where(sender: user).or(where(recipient: user)) }
  scope :with_associations, -> { includes(:sender, :recipient, sheet_requests: :sheet) }

  def self.create_with_requests(sender:, recipient:, sheet_ids:)
    allowed_ids = sender.sheets.with_content.where(id: sheet_ids).ids
    return if allowed_ids.empty?

    transaction do
      share = create!(sender: sender, recipient: recipient)
      share.sheet_requests.insert_all(allowed_ids.map { { sheet_id: _1, status: "pending" } })
      share
    end
  end
end
