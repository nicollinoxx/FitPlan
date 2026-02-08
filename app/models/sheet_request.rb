class SheetRequest < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :sheet

  validate :should_be_requestable, unless: -> { sheet.shareable? }, on: :create

  enum :status, { pending: "pending", accepted: "accepted", rejected: "rejected" }

  def sender?(user = Current.user)
    sender == user
  end

  def receiver?(user = Current.user)
    recipient == user
  end

  private

    def should_be_requestable
      error.add(:sheet, "should be private to request!")
    end
end
