module Sheets::RequestsHelper
  def sheet_type_badge_class(sheet)
    sheet.workout? ? "bg-success-subtle text-success" : "bg-orange-subtle text-orange"
  end
end
