module Completion::Completable
  extend ActiveSupport::Concern

  included do
    after_create :complete_sheet_if_all_done, if: :all_items_completed?
  end

  def sheet_completed?
    sheet.sheet_completions.where("created_at >= ?", created_at).exists?
  end

  private

  def all_items_completed?
    sheet.completions.current_round(sheet).distinct.count(item_by_sheet_type) == sheet_items.count
  end

  def complete_sheet_if_all_done
    sheet.sheet_completions.create!(user: sheet.user, completed_at: completed_at)
  end

  def item_by_sheet_type
    sheet.workout? ? :workout_id : :diet_id
  end

  def sheet_items
    sheet.workout? ? sheet.workouts : sheet.diets
  end
end
