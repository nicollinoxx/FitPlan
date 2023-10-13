class Treino < ApplicationRecord
  belongs_to :ficha

  validates :exercicio, :series, :repeticoes, presence: true
end
