module Sheets::SheetCopyable
  extend ActiveSupport::Concern

  def copy_content_to(copy_sheet)
    copy_workouts_to(copy_sheet) if workout?
    copy_diets_to(copy_sheet) if diet?
  end

  private

  def copy_workouts_to(target_sheet)
    workouts.find_each do |workout|
      target_sheet.workouts.create!(workout.attributes.except("id", "created_at", "updated_at"))
    end
  end

  def copy_diets_to(target_sheet)
    diets.find_each do |diet|
      target_sheet.diets.create!(diet.attributes.except("id", "created_at", "updated_at"))
    end
  end
end
