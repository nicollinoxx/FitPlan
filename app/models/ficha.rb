class Ficha < ApplicationRecord
  has_many :treinos, dependent: :destroy
end
