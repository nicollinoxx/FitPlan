class Ficha < ApplicationRecord
  has_many :treinos, dependent: :destroy
  has_many :diet, dependent: :destroy

  validates :nome, :tipo, presence: true
  validates :descricao, length: {minimum: 10, maximum: 80}, presence: true
end
