class Sheet < ApplicationRecord
  include Copyable

  belongs_to :user
  belongs_to :source_sheet, class_name: "Sheet", optional: true
  belongs_to :sheet_import, optional: true

  has_many :workouts,       dependent: :destroy
  has_many :diets,          dependent: :destroy
  has_many :sheet_requests, dependent: :destroy
  has_many :copied_sheets,  class_name: "Sheet", foreign_key: :source_sheet_id, dependent: :nullify
  has_many :product_items,  dependent: :destroy

  enum :visibility,  { shareable: "shareable", importable: "importable" }
  enum :sheet_type,  { workout: "workout", diet: "diet" }
  enum :origin_type, { direct_share: "direct_share", marketplace: "marketplace" }, prefix: :origin

  validates :sheet_type, inclusion: { in: %w[ workout diet ] }

  scope :search_by_type,       ->(type)       { sheet_types.keys.include?(type) ? where(sheet_type: type) : all }
  scope :search_by_visibility, ->(visibility) { visibilities.keys.include?(visibility) ? where(visibility: visibility) : all }
  scope :available_for_import, -> { importable.where(sheet_import_id: nil).where.not(copy: true).order(created_at: :desc) }
  scope :originals,            -> { where(copy: false) }
  scope :authored,             -> { where(sheet_import_id: nil) }
  scope :imported,             -> { where.not(sheet_import_id: nil) }

  after_update :destroy_invalid_content, if: :saved_change_to_sheet_type?

  def self.grouped_by(period)
    case period.to_s
    when "day"  then originals.group_by_day(:created_at).count
    when "week" then originals.group_by_week(:created_at).count
    when "year" then originals.group_by_year(:created_at).count
    else originals.group_by_month(:created_at).count
    end
  end

  def self.filtered_by(params)
    search_by_type(params[:type]).search_by_visibility(params[:visibility])
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
