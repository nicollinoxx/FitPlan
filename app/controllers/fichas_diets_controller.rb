class FichasDietsController < ApplicationController
  def index
    @fichas = Ficha.where(tipo: 'diet').order(:nome)
  end
end
