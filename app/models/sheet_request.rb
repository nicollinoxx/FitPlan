class SheetRequest < ApplicationRecord
  belongs_to :sheet_share
  belongs_to :sheet

  delegate :sender, :recipient, to: :sheet_share

  validates :sheet, presence: true

  validate :only_recipient_can_accept, on: :update, if: :accepted?

  enum :status, { pending: "pending", accepted: "accepted", rejected: "rejected" }, default: :pending

  scope :accessible_by, ->(user) {
    joins(:sheet_share).where("sheet_shares.sender_id = ? OR sheet_shares.recipient_id = ?", user.id, user.id)
  }

  after_update :copy_sheet_job, if: -> { saved_change_to_status?(to: "accepted") }
  after_destroy :destroy_share_if_empty

  def sender?(user = Current.user)
    sender == user
  end

  def receiver?(user = Current.user)
    recipient == user
  end

  private

    def copy_sheet_job
      CopySheetJob.perform_later(self)
    end

    def only_recipient_can_accept
      errors.add(:base, I18n.t("errors.sheet_request.not_recipient")) unless receiver?
    end

    def destroy_share_if_empty
      sheet_share.destroy if sheet_share.sheet_requests.empty?
    end
end
