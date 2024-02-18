module FichaScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_ficha
  end

  private
    def set_ficha
      @ficha = Ficha.find(params[:ficha_id])
    end
end
