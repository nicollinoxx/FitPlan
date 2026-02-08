class Sheet < ApplicationRecord
  include Copyable

  belongs_to :user

  has_many :workouts,       dependent: :destroy
  has_many :diets,          dependent: :destroy
  has_many :sheet_requests, dependent: :destroy

  enum :sheet_type, { workout: "workout", diet: "diet" }
  enum :visibility, { shareable: "sharable", visible: "visible", premium: "premium" }

  after_update :destroy_invalid_content, if: :saved_change_to_sheet_type?

  scope :search_by_type,       -> (type)      { sheet_types.keys.include?(type) ? where(sheet_type: type) : all }
  scope :search_by_visibility, -> (visibility) { visibilities.keys.include?(visibility) ? where(visibility: visibilities[visibility]) : all }
  scope :originals,            -> { where(copy: false) }

  def self.grouped_by(period)
    case period.to_s
    when "day"  then originals.group_by_day(:created_at).count
    when "week" then originals.group_by_week(:created_at).count
    when "year" then originals.group_by_year(:created_at).count
    else originals.group_by_month(:created_at).count
    end
  end

  def can_import?
    visible? || premium?
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
