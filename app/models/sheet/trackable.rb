module Sheet::Trackable
  extend ActiveSupport::Concern

  included do
    has_many :completions,       dependent: :destroy
    has_many :sheet_completions, dependent: :destroy

    has_many :sheet_completions_today, -> { today }, class_name: "SheetCompletion"

    scope :completed_today, -> { joins(:sheet_completions_today).distinct }
  end

  def completed_diets_indexed_by_diet_id
    completions.today.where.not(diet_id: nil).index_by(&:diet_id)
  end

  def completions_indexed_by_workout_id
    completions.current_round.where.not(workout_id: nil).index_by(&:workout_id)
  end

  def complete!
    transaction do
      sheet_completion = sheet_completions.create!(user: user)
      completions.current_round.update_all(sheet_completion_id: sheet_completion.id)
    end
  end

  def uncomplete!
    sheet_completions_today.order(:completed_at).last&.destroy!
  end

  def completed?
    sheet_completions_today.exists?
  end
end
