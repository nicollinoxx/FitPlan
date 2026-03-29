module WorkoutsHelper
  def workout_completion_button(sheet, workout, completed)
    if completed
      button_to sheet_workout_completions_path(sheet, workout), method: :delete, class: 'btn btn-sm btn-light' do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    else
      button_to sheet_workout_completions_path(sheet, workout), params: { completion: { workout_id: workout.id } }, class: 'btn btn-sm btn-outline-light' do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    end
  end
end
