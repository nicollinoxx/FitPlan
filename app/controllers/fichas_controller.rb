class FichasController < ApplicationController
  before_action :set_ficha, only: %i[ show edit update destroy ]

  # GET /fichas or /fichas.json
  def index
    @tipo = params[:tipo]
    if @tipo == 'diet'
      @fichas = Ficha.where(tipo: 'diet').order(:nome)
      @titulo = 'Fichas de dietas'
    elsif @tipo == 'treino'
      @fichas = Ficha.where(tipo: 'treino').order(:nome)
      @titulo = 'Fichas de treinos'
    else
      @fichas = Ficha.all.order(:nome)
      @titulo = 'Fichas'
    end
  end

  # GET /fichas/1 or /fichas/1.json
  def show
  end

  # GET /fichas/new
  def new
    @ficha = Ficha.new
    @action = 'Criar'
  end

  # GET /fichas/1/edit
  def edit
    @action = 'Editar'
  end

  # POST /fichas or /fichas.json
  def create
    @ficha = Ficha.new(ficha_params)

    respond_to do |format|
      if @ficha.save
        format.html { redirect_to ficha_url(@ficha), notice: "Ficha was successfully created." }
        format.json { render :show, status: :created, location: @ficha }
      else
        @action = 'Criar'
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ficha.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fichas/1 or /fichas/1.json
  def update
    respond_to do |format|
      if @ficha.update(ficha_params)
        format.html { redirect_to ficha_url(@ficha), notice: "Ficha was successfully updated." }
        format.json { render :show, status: :ok, location: @ficha }
      else
          @action = 'Editar'
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ficha.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fichas/1 or /fichas/1.json
  def destroy
    @ficha.destroy

    respond_to do |format|
      format.html { redirect_to fichas_url, notice: "A foi destruida com sucesso." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_ficha
      @ficha = Ficha.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to fichas_url, notice: 'Ficha não foi encontrada ou não existe'
    end

    # Only allow a list of trusted parameters through.
    def ficha_params
      params.require(:ficha).permit(:nome, :tipo, :descricao)
    end
end
