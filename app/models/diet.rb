class Diet < ApplicationRecord
  include DietCalculator

  belongs_to :sheet

  has_rich_text :description

  validates :meal, :description, :protein_g, :carbohydrate_g, :fat_g, presence: true
end
