class Sheet < ApplicationRecord
  belongs_to :user
  has_many   :workouts, dependent: :destroy
  has_many   :diets,    dependent: :destroy

  validates :name, :sheet_type, presence: true
  validates :sheet_type, inclusion: { in: %w(workout diet) }

  before_update :destroy_invalid_content, if: :will_save_change_to_sheet_type?

  def workout?
    sheet_type == 'workout'
  end

  def diet?
    sheet_type == 'diet'
  end

  private

  def destroy_invalid_content
    diets.destroy_all if sheet_type == 'workout'

    workouts.destroy_all if sheet_type == 'diet'
  end
end
