class SharedSheet < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :sheet

  enum :status, { pending: "pending", accepted: "accepted", rejected: "rejected" }

  def owner? = (sender == Current.user)
  def receiver? = (recipient == Current.user)

  private

    def self.filtered_for(user, filter)
      if filter == "sent"
        user.sent_shared_sheets.includes(:recipient)
      else
        user.received_shared_sheets.includes(:sender)
      end
    end
end
