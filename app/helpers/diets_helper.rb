module DietsHelper
  def diet_completion_button(sheet, diet, completed)
    completion_toggle_button(sheet_diet_completion_path(sheet, diet), completed)
  end
end
