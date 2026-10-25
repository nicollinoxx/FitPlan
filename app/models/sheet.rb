class Sheet < ApplicationRecord
  include Normalizable
  include Copyable
  include Positionable
  include Trackable

  belongs_to :user
  positioned_within :user

  has_many :workouts,          dependent: :destroy
  has_many :diets,             dependent: :destroy
  has_many :sheet_requests,    dependent: :destroy

  validates :sheet_type, inclusion: { in: %w[ workout diet ] }
  validates :name, presence: true

  enum :sheet_type, { workout: "workout", diet: "diet" }

  after_update :destroy_invalid_content, if: :saved_change_to_sheet_type?

  scope :search_by_type,  ->(type) { sheet_types.keys.include?(type) ? where(sheet_type: type) : all }
  scope :search_by_name,  ->(name) { name.present? ? where("name ILIKE ?", "%#{sanitize_search(name)}%") : all }
  scope :has_workouts,    -> { where(Workout.where("workouts.sheet_id = sheets.id").arel.exists) }
  scope :has_diets,       -> { where(Diet.where("diets.sheet_id = sheets.id").arel.exists) }
  scope :with_content,    -> { has_workouts.or(has_diets) }

  def self.filter_by(type, completed, search = nil)
    case completed.to_s
    when 'true'  then search_by_type(type).completed_today.search_by_name(search)
    when 'false' then search_by_type(type).where.missing(:sheet_completions_today).search_by_name(search)
    else              search_by_type(type).search_by_name(search)
    end
  end

  def self.generate_from_recommendation!(sheets_attributes)
    transaction do
      sheets_attributes.map.with_index(1) do |attributes, position|
        create!(attributes.slice(:name, :description, :sheet_type).merge(suggested: true)).tap do |sheet|
          sheet.update!(position: position)
          sheet.add_recommended!(attributes.fetch(sheet.workout? ? :workouts : :diets, []))
        end
      end
    end
  end

  def add_recommended!(items)
    (workout? ? workouts : diets).create!(items)
  end

  def origin
    return :copied    if copy?
    return :suggested if suggested?

    :manual
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
