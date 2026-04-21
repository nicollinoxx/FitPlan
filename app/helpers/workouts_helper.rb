module WorkoutsHelper
  def workout_completion_button(sheet, workout, completion)
    spinner_icon = content_tag(:i, '', class: 'bi bi-hourglass-split')

    if completion&.series_zero?
      button_to sheet_workout_completion_path(sheet, workout), method: :delete, class: 'btn btn-sm btn-light', data: { turbo_submits_with: spinner_icon } do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    else
      button_to sheet_workout_completion_path(sheet, workout), class: 'btn btn-sm btn-light', data: { turbo_submits_with: spinner_icon } do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    end
  end

  def workout_reset_button(sheet, workout, completion)
    return unless completion.present?

    remaining_series = completion.remaining_series.to_i
    return if remaining_series.zero? || remaining_series >= workout.series

    button_to sheet_workout_completion_path(sheet, workout), method: :delete,
      class: 'btn btn-sm btn-success position-absolute top-0 end-0 translate-middle px-3 py-0 lh-1' do
      content_tag(:i, '', class: 'bi bi-arrow-counterclockwise text-light')
    end
  end
end
