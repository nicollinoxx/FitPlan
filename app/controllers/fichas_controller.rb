class FichasController < ApplicationController
  before_action :set_ficha, only: %i[ show edit update destroy ]
  before_action :set_notice, only: %i[ show ]

  # GET /fichas or /fichas.json
  def index
    @fichas = Ficha.order('created_at desc')
    @titulo = 'Fichas'
  end

  # GET /fichas/1 or /fichas/1.json
  def show
  end

  # GET /fichas/new
  def new
    @ficha = Ficha.new
    @action = 'Criar'
    @ficha.tipo = params[:tipo]
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
        format.html { refresh_or_redirect_to ficha_url(@ficha), notice: "Ficha was successfully created." }
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
      format.html { refresh_or_redirect_to fichas_url, notice: "A #{@ficha.nome} foi destruida com sucesso." }
      format.json { head :no_content }
    end
  end

  def show_ficha_diets
    @fichas = Ficha.where(tipo: 'diet').order('created_at desc')
  end

  def show_ficha_treinos
    @fichas = Ficha.where(tipo: 'treino').order('created_at desc')
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

    def set_notice
      if @ficha.diets.count == 0 && @ficha.treinos.count == 0
        flash[:message] = 'Hum, parece que esta ficha ainda esta vazia'
      else
        flash[:message] = nil
      end
    end
end
