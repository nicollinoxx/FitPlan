class Sheets::CreateSheetCloneJob < ApplicationJob
  queue_as :default

  def perform(sheet, user)
    sheet_clone = build_sheet_clone(sheet, user)
    clone_items(sheet, sheet_clone) if sheet_clone.save
  end

  private

  def build_sheet_clone(sheet, user)
    user.sheets.build(sheet.attributes.except("id", "created_at", "updated_at"))
  end

  def clone_items(sheet, sheet_clone)
    items = sheet.workout? ? sheet.workouts : sheet.diets
    items.each { |item| clone_item(item, sheet_clone) }
  end

  def clone_item(item, sheet_clone)
    new_item = item.clone
    new_item.sheet = sheet_clone
    new_item.save
  end
end
