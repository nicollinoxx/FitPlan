module Sheets::RequestsHelper
  def preview_path(request, filter: nil)
    if request.sheet.workout?
      preview_sheet_workouts_path(request.sheet, filter: filter)
    else
      preview_sheet_diets_path(request.sheet, filter: filter)
    end
  end
end
