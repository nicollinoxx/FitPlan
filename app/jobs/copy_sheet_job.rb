class CopySheetJob < ApplicationJob
  retry_on ActiveRecord::RecordInvalid, wait: ->(executions) { executions * 3.minutes }, attempts: 3

  queue_as :default

  def perform(request)
    sheet     = request.sheet
    recipient = request.recipient

    request.destroy if sheet.copy_to recipient
  end
end
