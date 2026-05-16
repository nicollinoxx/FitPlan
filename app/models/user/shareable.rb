module User::Shareable
  extend ActiveSupport::Concern

  included do
    has_many :sent_sheet_shares,       class_name: "SheetShare",        foreign_key: :sender_id,    dependent: :destroy
    has_many :received_sheet_shares,   class_name: "SheetShare",        foreign_key: :recipient_id, dependent: :destroy
    has_many :sent_sheet_requests,     through: :sent_sheet_shares,     source: :sheet_requests
    has_many :received_sheet_requests, through: :received_sheet_shares, source: :sheet_requests
  end

  def sheet_shares_by_filter(filter)
    if filter == "sent"
      sent_sheet_shares.includes(:recipient, sheet_requests: :sheet)
    else
      received_sheet_shares.includes(:sender, sheet_requests: :sheet)
    end
  end
end
