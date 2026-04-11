module SheetsHelper
  def sheet_color(sheet)
    sheet.workout? ? "success" : "warning"
  end

  def sheet_diets_or_workouts_path(sheet)
    sheet.workout? ? sheet_workouts_path(sheet) : sheet_diets_path(sheet)
  end

  def sheet_completions_today_badge(sheet)
    count = sheet.sheet_completions_today.size
    return if count.zero?

    content_tag(:span, "#{count}x #{t('today')}",
                class: "position-absolute bottom-0 end-0 m-2 badge bg-#{sheet_color(sheet)} text-light",
                style: "z-index: 10;")
  end

  def sheet_completion_button(sheet)
    if sheet.completed?
      button_to sheet_completion_path(sheet), method: :delete, data: { turbo_frame: "sheets" }, class: "btn btn-sm btn-outline-danger" do
        content_tag(:i, '', class: 'bi bi-x-lg')
      end
    else
      button_to sheet_completion_path(sheet), data: { turbo_frame: "_refresh" }, class: "btn btn-sm btn-outline-success" do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    end
  end
end
