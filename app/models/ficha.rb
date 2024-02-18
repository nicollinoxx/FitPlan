class Ficha < ApplicationRecord
  has_many :treinos, dependent: :destroy
  has_many :dietas,  dependent: :destroy

  validates :nome, :tipo, :descricao, presence: true
end
