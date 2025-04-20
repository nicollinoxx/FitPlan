module DietCalculator
  extend ActiveSupport::Concern

  included do
    before_save :calculate_calories
  end

  def calculate_percentage_of_calories
    return if calories.zero?

    percentage = {
      protein: (protein_g * 4 / calories.to_f * 100).round(2),
      carbohydrate: (carbohydrate_g * 4 / calories.to_f * 100).round(2),
      fat: (fat_g * 9 / calories.to_f * 100).round(2)
    }
  end

  private

    def calculate_calories
      self.calories = ((protein_g.to_f * 4) + (carbohydrate_g.to_f * 4) + (fat_g.to_f * 9)).round(2)
    end
end
