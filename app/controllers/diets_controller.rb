class DietsController < ApplicationController
  include CurrentFicha
  before_action :set_ficha
  before_action :set_diet, only: %i[ show edit update destroy ]

  # GET /diets or /diets.json
  def index
    @diets = @ficha.diet.all
  end

  # GET /diets/1 or /diets/1.json
  def show
  end

  # GET /diets/new
  def new
    @diet = Diet.new
    @action = 'Criar'
  end

  # GET /diets/1/edit
  def edit
    @action = 'Editar'
  end

  # POST /diets or /diets.json
  def create
    @diet = @ficha.diet.new(diet_params)

    respond_to do |format|
      if @diet.save
        @diet.calcular_kcal
        format.html { redirect_to ficha_diet_url(@ficha, @diet), notice: "Diet was successfully created." }
        format.json { render :show, status: :created, location: @diet }
      else
        @action = 'Criar'
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @diet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /diets/1 or /diets/1.json
  def update
    respond_to do |format|
      if @diet.update(diet_params)
        @diet.calcular_kcal
        format.html { refresh_or_redirect_to ficha_diet_url(@ficha, @diet), notice: "Diet was successfully updated." }
        format.json { render :show, status: :ok, location: @diet }
      else
        @action = 'Edit'
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @diet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diets/1 or /diets/1.json
  def destroy
    @diet.destroy

    respond_to do |format|
      format.html { redirect_to root_url, notice: "Diet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_diet
      @diet = @ficha.diet.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      recede_or_redirect_to fichas_url
    end

    # Only allow a list of trusted parameters through.
    def diet_params
      params.require(:diet).permit(:refeicao, :descricao, :proteina_g, :carboidratos_g, :gordura_g, :calorias)
    end
end
