class Treino < ApplicationRecord
  validates :exercicio, :series, :repeticoes, presence: true
end
