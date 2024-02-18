class Treino < ApplicationRecord
  has_one_attached :video
  belongs_to :ficha

  validates :exercicio, :series, :repeticoes, presence: true
end
