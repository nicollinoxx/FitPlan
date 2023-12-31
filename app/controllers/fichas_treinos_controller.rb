class FichasTreinosController < ApplicationController
  def index
    @fichas = Ficha.where(tipo: 'treino').order(:nome)
  end
end
