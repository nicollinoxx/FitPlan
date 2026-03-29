module DietsHelper
  def diet_completion_button(sheet, diet, completed)
    if completed
      button_to sheet_diet_completion_path(sheet, diet, diet.completion_on_round.last), method: :delete, class: 'btn btn-sm btn-light' do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    else
      button_to sheet_diet_completions_path(sheet, diet), params: { completion: { diet_id: diet.id } }, class: 'btn btn-sm btn-outline-light' do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    end
  end
end
