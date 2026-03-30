module WorkoutsHelper
  def workout_completion_button(sheet, workout, completed)
    completion_toggle_button(sheet_workout_completion_path(sheet, workout), completed)
  end
end
