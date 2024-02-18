class DietasController < ApplicationController
  include FichaScoped

  before_action :set_ficha
  before_action :set_dieta, only: %i[ show edit update destroy ]

  # GET /diets or /dietas.json
  def index
    @dietas = @ficha.dietas.all
  end

  # GET /dietas/1 or /dietas/1.json
  def show
  end

  # GET /dietas/new
  def new
    @dieta = Dieta.new
  end

  # GET /dietas/1/edit
  def edit
  end

  # POST /dietas or /dietas.json
  def create
    @dieta = @ficha.dietas.new(dieta_params)

    respond_to do |format|
      if @dieta.save
        format.html { refresh_or_redirect_to ficha_dieta_url(@ficha, @dieta), notice: "Dieta foi criada com sucesso." }
        format.json { render :show, status: :created, location: @dieta }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dieta.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dietas/1 or /dietas/1.json
  def update
    respond_to do |format|

      if @dieta.update(dieta_params)
        format.html { refresh_or_redirect_to ficha_dieta_url(@ficha, @dieta), notice: "Dieta foi atualizada com sucesso." }
        format.json { render :show, status: :ok, location: @dieta }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dieta.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dietas/1 or /dietas/1.json
  def destroy
    @dieta.destroy

    respond_to do |format|
      format.html { recede_or_redirect_to ficha_diet_path(@ficha), notice: "Dieta foi destruido com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    def set_dieta
      @dieta = @ficha.dietas.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dieta_params
      params.require(:dieta).permit(:refeicao, :descricao, :proteina_g, :carboidratos_g, :gordura_g, :calorias)
    end
end
