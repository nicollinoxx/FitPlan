module SheetsHelper
  def sheet_diets_or_workouts_path(sheet)
    sheet.workout? ? sheet_workouts_path(sheet) : sheet_diets_path(sheet)
  end

  def visibility_badge_class(sheet)
    case sheet.visibility
    when "shareable" then "bg-primary-subtle text-primary"
    when "visible"   then "bg-secondary-subtle text-body"
    when "premium"   then "bg-purple-subtle text-purple"
    end
  end
end
