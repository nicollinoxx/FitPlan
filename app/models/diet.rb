class Diet < ApplicationRecord
  belongs_to :sheet

  validates :meal, :description, :protein_g, :carbohydrate_g, :fat_g, presence: true

  before_save :calculate_calories

  def calculate_calories
    self.calories = (protein_g.to_f * 4) + (carbohydrate_g.to_f * 4) + (fat_g.to_f * 9)
  end
end
