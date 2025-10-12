class CopySheetJob < ApplicationJob
  queue_as :default

  def perform(sheet_request)
    sheet     = sheet_request.sheet
    recipient = sheet_request.recipient

    sheet_request.destroy if sheet.copy_sheet(recipient)
  end
end
