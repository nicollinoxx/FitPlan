class Ficha < ApplicationRecord
  has_many :treinos, dependent: :destroy
  has_many :diets, dependent: :destroy

  validates :nome, :tipo, :descricao, presence: true
end
