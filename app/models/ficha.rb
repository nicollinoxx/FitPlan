class Ficha < ApplicationRecord
  has_many :treinos, dependent: :destroy
  has_many :diets, dependent: :destroy

  validates :nome, :tipo, presence: true
  validates :descricao, length: {minimum: 10, maximum: 120}, presence: true
end
