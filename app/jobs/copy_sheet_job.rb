class CopySheetJob < ApplicationJob
  queue_as :default

  def perform(recipient, sheet)
    sheet.copy_sheet(recipient)
  end
end
