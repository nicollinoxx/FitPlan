module Sheets::RequestsHelper
  def sheet_type_badge_class(sheet)
    sheet.workout? ? "bg-danger-subtle text-danger" : "bg-warning-subtle text-warning"
  end
end
