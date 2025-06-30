class Sheet < ApplicationRecord
  include Sheets::SheetCopyable

  belongs_to :user
  has_many   :workouts, dependent: :destroy
  has_many   :diets,    dependent: :destroy

  validates :name, :sheet_type, presence: true
  validates :sheet_type, inclusion: { in: %w(workout diet) }

  enum :sheet_type, { workout: "workout", diet: "diet" }

  after_update :destroy_invalid_content, if: :saved_change_to_sheet_type?

  private

    def destroy_invalid_content
      if workout?
        diets.destroy_all
      elsif diet?
        workouts.destroy_all
      end
    end
end
