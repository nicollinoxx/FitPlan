module ApplicationHelper
  def completion_toggle_button(path, completed)
    spinner_icon = content_tag(:i, '', class: 'bi-hourglass-split')

    if completed
      button_to path, method: :delete, class: 'btn btn-sm btn-light', data: { turbo_submits_with: spinner_icon } do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    else
      button_to path, class: 'btn btn-sm btn-outline-light', data: { turbo_submits_with: spinner_icon } do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    end
  end
end
