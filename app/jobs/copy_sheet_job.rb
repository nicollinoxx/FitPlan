class CopySheetJob < ApplicationJob
  queue_as :default

  def perform(recipient_id, sheet_id)
    recipient = User.find(recipient_id)
    sheet = Sheet.find(sheet_id)

    sheet.copy_sheet(recipient)
  end
end
