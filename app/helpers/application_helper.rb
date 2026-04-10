module ApplicationHelper
  def completion_toggle_button(path, completed)
    if completed
      button_to path, method: :delete, class: 'btn btn-sm btn-light' do
        content_tag(:i, '', class: 'bi bi-x-lg')
      end
    else
      button_to path, class: 'btn btn-sm btn-outline-light' do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    end
  end
end
