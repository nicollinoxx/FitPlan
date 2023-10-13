module CurrentFicha
  def set_ficha
    @ficha = Ficha.find(params[:ficha_id])
  end
end
