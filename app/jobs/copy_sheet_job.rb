class CopySheetJob < ApplicationJob
  retry_on ActiveRecord::RecordInvalid, wait: ->(executions) { executions * 3.minutes }, attempts: 3

  queue_as :default

  def perform(sheet_request)
    sheet     = sheet_request.sheet
    recipient = sheet_request.recipient

    sheet_request.destroy if sheet.copy_to recipient
  end
end
