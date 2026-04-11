class Sheet < ApplicationRecord
  include Sheet::Copyable

  belongs_to :user

  has_many :workouts, dependent: :destroy
  has_many :diets,    dependent: :destroy
  has_many :completions, dependent: :destroy
  has_many :sheet_requests, dependent: :destroy
  has_many :sheet_completions, dependent: :destroy
  has_many :sheet_completions_today, -> { today }, class_name: "SheetCompletion"

  validates :sheet_type, inclusion: { in: %w[ workout diet ] }

  enum :sheet_type, { workout: "workout", diet: "diet" }

  after_update :destroy_invalid_content, if: :saved_change_to_sheet_type?

  scope :search_by_type,  ->(type) { sheet_types.keys.include?(type) ? where(sheet_type: type) : all }
  scope :completed_today, -> { joins(:sheet_completions_today).distinct }

  def self.filter_by(type, completed)
    if completed.to_s == 'true'
      search_by_type(type).completed_today
    else
      search_by_type(type)
    end
  end

  def completions_in_current_round
    completions.current_round
  end

  def completed_diet_ids
    completions.today.where.not(diet_id: nil).pluck(:diet_id).to_set
  end

  def completions_indexed_by_workout_id
    completions_in_current_round.where.not(workout_id: nil).index_by(&:workout_id)
  end

  def completed?
    sheet_completions_today.exists?
  end

  def complete!
    workout? ? mark_sheet_completion! : complete_all_diets!
  end

  def uncomplete!
    sheet_completions_today.order(:completed_at).last&.destroy!
  end

  def mark_sheet_completion!
    transaction do
      sheet_completion = sheet_completions.create!(user: user, completed_at: Time.current)
      completions.current_round.update_all(sheet_completion_id: sheet_completion.id)
    end
  end

  private

    def complete_all_diets!
      diets.find_each { |diet| completions.today.find_or_create_by!(diet: diet) }
      mark_sheet_completion! unless completed?
    end

    def destroy_invalid_content
      if workout?
        diets.destroy_all
      elsif diet?
        workouts.destroy_all
      end
    end
end
