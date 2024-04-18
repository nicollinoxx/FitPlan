class Diet < ApplicationRecord
  belongs_to :sheet

  has_rich_text :description
  validates :meal, :description, presence: true

  before_save :calculate_calories
  def calculate_calories
    self.calories = (protein_g.to_f * 4) + (carbohydrate_g.to_f * 4) + (fat_g.to_f * 9)
  end
end
