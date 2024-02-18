class Dieta < ApplicationRecord
  before_save :calcular_kcal

  has_rich_text :decricao

  belongs_to :ficha
  validates :refeicao, :descricao, presence: true

  def calcular_kcal
    proteina_kcal = proteina_g.to_f * 4
    carboidratos_kcal = carboidratos_g.to_f * 4
    gordura_kcal = gordura_g.to_f * 9

    self.calorias = proteina_kcal + carboidratos_kcal + gordura_kcal
  end
end
