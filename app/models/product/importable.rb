module Product::Importable
  def import_to user
    sheet_import = sheet_imports.create!(user: user, status: "pending")

    transaction do
      create_copy_sheets_to sheet_import
      sheet_import.update!(status: "completed", imported_at: Time.current)
    end

    sheet_import
  rescue StandardError
    sheet_import.update!(:status, "failed")
    raise
  end

  private

  def create_copy_sheets_to sheet_import
    product_items.includes(:sheet).map do |item|
      item.sheet.copy_to(user, origin_type: :marketplace, sheet_import: sheet_import)
    end
  end
end
