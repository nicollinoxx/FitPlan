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
  scope :filter_by,       ->(type, completed) { completed ? search_by_type(type).completed_today : search_by_type(type) }

  def self.grouped_by(period)
    case period.to_s
    when "day"  then group_by_day(:created_at).count
    when "week" then group_by_week(:created_at).count
    when "year" then group_by_year(:created_at).count
    else group_by_month(:created_at).count
    end
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
