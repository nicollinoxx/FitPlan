class DietsController < ApplicationController
  include CurrentFicha
  before_action :set_ficha
  before_action :set_diet, only: %i[ show edit update destroy ]

  # GET /diets or /diets.json
  def index
    @diets = @ficha.diets.all
  end

  # GET /diets/1 or /diets/1.json
  def show
  end

  # GET /diets/new
  def new
    @diet = Diet.new
  end

  # GET /diets/1/edit
  def edit
  end

  # POST /diets or /diets.json
  def create
    @diet = @ficha.diets.new(diet_params)

    respond_to do |format|
      if @diet.save
        format.html { refresh_or_redirect_to ficha_diet_url(@ficha, @diet), notice: "Dieta foi criada com sucesso." }
        format.json { render :show, status: :created, location: @diet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @diet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /diets/1 or /diets/1.json
  def update
    respond_to do |format|

      if @diet.update(diet_params)
        format.html { refresh_or_redirect_to ficha_diet_url(@ficha, @diet), notice: "Dieta foi atualizada com sucesso." }
        format.json { render :show, status: :ok, location: @diet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @diet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diets/1 or /diets/1.json
  def destroy
    @diet.destroy

    respond_to do |format|
      format.html { recede_or_redirect_to ficha_diet_path(@ficha), notice: "Dieta foi destruido com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    def set_diet
      @diet = @ficha.diets.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      recede_or_redirect_to fichas_url
    end

    # Only allow a list of trusted parameters through.
    def diet_params
      params.require(:diet).permit(:refeicao, :descricao, :proteina_g, :carboidratos_g, :gordura_g, :calorias)
    end
end
