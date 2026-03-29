module Completion::Completable
  extend ActiveSupport::Concern

  included do
    after_create :complete_sheet_if_all_done
  end

  private

  def complete_sheet_if_all_done
    counts = completion_counts

    return unless all_items_completed?(counts) && new_round?(counts)
    sheet.sheet_completions.create!(user: user, completed_at: Time.current)
  end

  def completion_counts
    item_key = sheet.workout? ? :workout_id : :diet_id
    sheet.completions.today.group(item_key).count
  end

  def all_items_completed?(counts)
    counts.size == items_count
  end

  def new_round?(counts)
    counts.values.min > sheet.sheet_completions.today.count
  end

  def items_count
    sheet.workout? ? sheet.workouts.count : sheet.diets.count
  end
end
