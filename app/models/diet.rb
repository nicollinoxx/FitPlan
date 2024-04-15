class Diet < ApplicationRecord
  has_rich_text :description
  
  validates :snack, :description, presence: true

  before_save :calculate_calories
  def calculate_calories
    self.calories = (protein_g * 4) + (carbohydrate_g * 4) + (fat_kcal = fat_g * 9)
  end
end
