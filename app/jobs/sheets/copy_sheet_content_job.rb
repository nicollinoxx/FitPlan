class Sheets::CopySheetContentJob < ApplicationJob
  queue_as :default

  def perform(original_id, copy_id)
    original = Sheet.find(original_id)
    copy = Sheet.find(copy_id)
    original.copy_content_to(copy)
  end
end
