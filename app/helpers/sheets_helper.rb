module SheetsHelper
  def sheet_diets_or_workouts_path(sheet)
    sheet.workout? ? sheet_workouts_path(sheet) : sheet_diets_path(sheet)
  end
end
