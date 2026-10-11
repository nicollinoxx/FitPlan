class Diet < ApplicationRecord
  include Positionable

  belongs_to :sheet
  positioned_within :sheet

  has_rich_text :description

  has_many :completions, dependent: :destroy

  validates :meal, presence: true

  before_save :calculate_calories

  def percentage_of_calories
    { protein: (protein_g * 4 / calories * 100).round(2),
      carbohydrate: (carbohydrate_g * 4 / calories * 100).round(2),
      fat: (fat_g * 9 / calories * 100).round(2) }
  end

  private

    def calculate_calories
      self.calories = ((protein_g.to_f * 4) + (carbohydrate_g.to_f * 4) + (fat_g.to_f * 9)).round(2)
    end
end
