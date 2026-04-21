module DietsHelper
  def diet_completion_button(sheet, diet, completed)
    spinner_icon = content_tag(:i, '', class: 'bi bi-hourglass-split')

    if completed.present?
      button_to sheet_diet_completion_path(sheet, diet), method: :delete, class: 'btn btn-sm btn-light', data: { turbo_submits_with: spinner_icon } do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    else
      button_to sheet_diet_completion_path(sheet, diet), class: 'btn btn-sm btn-outline-light', data: { turbo_submits_with: spinner_icon } do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    end
  end
end
