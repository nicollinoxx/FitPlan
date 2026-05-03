module SheetsHelper
  def sheet_color(sheet)
    sheet.workout? ? "success" : "warning"
  end

  def sheet_diets_or_workouts_path(sheet)
    sheet.workout? ? sheet_workouts_path(sheet) : sheet_diets_path(sheet)
  end

  def sheet_completion_button(sheet)
    if sheet.completed?
      button_to sheet_completion_path(sheet), method: :delete, data: { turbo_frame: "sheets" }, class: "btn btn-sm btn-danger" do
        content_tag(:i, '', class: 'bi bi-x-lg')
      end
    else
      button_to sheet_completion_path(sheet), data: { turbo_frame: "sheets" }, class: "btn btn-sm btn-success" do
        content_tag(:i, '', class: 'bi bi-check-lg')
      end
    end
  end

   def sheet_filter_params(type: params[:type], completed: params[:completed])
    { type: type, completed: completed, search: params[:search] }
  end
end
