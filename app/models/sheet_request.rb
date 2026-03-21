class SheetRequest < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :sheet

  validates :sender, :recipient, :sheet, presence: true

  validate :can_accept_request, on: :update, if: :accepted?
  validate :sheet_must_be_shareable
  validate :sheet_must_belong_to_sender

  enum :status, { pending: "pending", accepted: "accepted" }

  def sender?(user = Current.user)
    sender == user
  end

  def receiver?(user = Current.user)
    recipient == user
  end

  def self.create_for_sheets(sender:, recipient:, sheet_ids:)
    return if sheet_ids.empty? || sheet_ids.size > 5

    transaction do
      sheet_ids.each do |sheet_id|
        create!(sender: sender, recipient: recipient, sheet_id: sheet_id, status: "pending")
      end
    end
  end

  private

    def sheet_must_belong_to_sender
      errors.add(:sheet, :invalid) unless sheet.user_id == sender_id
    end

    def can_accept_request
      errors.add(:base, I18n.t("errors.sheet_request.not_recipient")) unless receiver?
    end

    def sheet_must_be_shareable
      errors.add(:sheet, :invalid) unless sheet.present? || sheet.shareable?
    end
end
