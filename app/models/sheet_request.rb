class SheetRequest < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :sheet

  enum :status, { pending: "pending", accepted: "accepted", rejected: "rejected" }

  def sender?   = (sender == Current.user)
  def receiver? = (recipient == Current.user)
end
