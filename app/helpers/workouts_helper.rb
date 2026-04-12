module WorkoutsHelper
  def workout_completion_button(sheet, workout, completion)
    completion_toggle_button(sheet_workout_completion_path(sheet, workout), completion&.remaining_series&.zero?)
  end

  def workout_reset_button(sheet, workout, completion)
    return unless completion && !completion.remaining_series.zero? && completion.remaining_series < workout.series

    button_to sheet_workout_completion_path(sheet, workout), method: :delete,
      class: 'btn btn-sm btn-success position-absolute top-0 end-0 translate-middle px-3 py-0 lh-1' do
      content_tag(:i, '', class: 'bi bi-arrow-counterclockwise text-light')
    end
  end
end
