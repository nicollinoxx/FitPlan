class Sheet < ApplicationRecord
  include Sheet::Copyable

  belongs_to :user

  has_many :workouts, dependent: :destroy
  has_many :diets,    dependent: :destroy
  has_many :sheet_requests, dependent: :destroy

  validates :sheet_type, inclusion: { in: %w[ workout diet ] }

  enum :sheet_type, { workout: "workout", diet: "diet" }

  after_update :destroy_invalid_content, if: :saved_change_to_sheet_type?

  scope :search_by_type, ->(type) { sheet_types.keys.include?(type) ? where(sheet_type: type) : all }

  private

    def destroy_invalid_content
      if workout?
        diets.destroy_all
      elsif diet?
        workouts.destroy_all
      end
    end
end
