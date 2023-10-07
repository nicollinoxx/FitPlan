class Diet < ApplicationRecord
  validates :refeicao, :descricao, presence: true

  def calcular_kcal
    if proteina_g
      proteina_kcal = proteina_g * 4
    else
      proteina_kcal = 0
    end

    if carboidratos_g
      carboidratos_kcal = carboidratos_g * 4
    else
      carboidratos_kcal = 0
    end

    if gordura_g
      gordura_kcal = gordura_g * 9
    else
      gordura_kcal = 0
    end

    calorias_kcal = (proteina_kcal + carboidratos_kcal + gordura_kcal)
    update(calorias: calorias_kcal)
  end
end
