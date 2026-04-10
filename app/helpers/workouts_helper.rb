module WorkoutsHelper
  def workout_completion_button(sheet, workout, completion)
    completion_toggle_button(sheet_workout_completion_path(sheet, workout), completion&.remaining_series&.zero?)
  end
end
