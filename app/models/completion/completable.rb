module Completion::Completable
  extend ActiveSupport::Concern

  included do
    after_save :complete_sheet, if: :should_complete_sheet?
  end

  def sheet_completed?
    sheet.sheet_completions.where("created_at >= ?", created_at).exists?
  end

  private

    def complete_sheet
      sheet.sheet_completions.create!(user: sheet.user, completed_at: completed_at) if all_items_completed?
    end

    def should_complete_sheet?
      !sheet_completed? && (diet_id.present? || workout_just_finished?)
    end

    def workout_just_finished?
      workout_id.present? && saved_change_to_remaining_series? && remaining_series&.zero?
    end

    def all_items_completed?
      if sheet.workout?
        sheet.completions_in_current_round.where(remaining_series: 0).distinct.count(:workout_id) == sheet.workouts.count
      elsif sheet.diet?
        sheet.completions.today.distinct.count(:diet_id) == sheet.diets.count
      end
    end
end
