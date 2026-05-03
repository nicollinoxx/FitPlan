class Sheet < ApplicationRecord
  include Sheet::Copyable

  belongs_to :user

  has_many :workouts,          dependent: :destroy
  has_many :diets,             dependent: :destroy
  has_many :completions,       dependent: :destroy
  has_many :sheet_requests,    dependent: :destroy
  has_many :sheet_completions, dependent: :destroy

  has_many :sheet_completions_today, -> { today }, class_name: "SheetCompletion"

  validates :sheet_type, inclusion: { in: %w[ workout diet ] }

  enum :sheet_type, { workout: "workout", diet: "diet" }

  after_update :destroy_invalid_content, if: :saved_change_to_sheet_type?

  scope :search_by_type,  ->(type) { sheet_types.keys.include?(type) ? where(sheet_type: type) : all }
  scope :completed_today, -> { joins(:sheet_completions_today).distinct }
  scope :search_by_name,  ->(name) { name.present? ? where("name ILIKE ?", "%#{name}%") : all }

  def self.filter_by(type, completed, search = nil)
    case completed.to_s
    when 'true'  then search_by_type(type).completed_today.search_by_name(search)
    when 'false' then search_by_type(type).where.missing(:sheet_completions_today).search_by_name(search)
    else              search_by_type(type).search_by_name(search)
    end
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

  private

    def destroy_invalid_content
      if workout?
        diets.destroy_all
      elsif diet?
        workouts.destroy_all
      end
    end
end
