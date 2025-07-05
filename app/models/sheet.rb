class Sheet < ApplicationRecord
  include SheetCopyable

  belongs_to :user

  has_many :workouts, dependent: :destroy
  has_many :diets,    dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :name, :sheet_type, presence: true
  validates :sheet_type, inclusion: { in: %w(workout diet) }

  enum :sheet_type, { workout: "workout", diet: "diet" }

  after_update :destroy_invalid_content, if: :saved_change_to_sheet_type?

  def accept_notification(recipient_id)
    CopySheetJob.perform_later(recipient_id, self.id)
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
