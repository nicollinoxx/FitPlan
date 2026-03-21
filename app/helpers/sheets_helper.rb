module SheetsHelper
  def sheet_diets_or_workouts_path(sheet)
    sheet.workout? ? sheet_workouts_path(sheet) : sheet_diets_path(sheet)
  end

  def sheet_type_badge_class(sheet)
    sheet.workout? ? "bg-success-subtle text-success" : "bg-warning-subtle text-warning"
  end

  def visibility_badge_class(sheet)
    case sheet.visibility
    when "shareable"  then "bg-purple-subtle text-purple"
    when "importable" then "bg-primary-subtle text-primary-emphasis"
    else "bg-body-secondary text-body"
    end
  end
end
