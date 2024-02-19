class FichasController < ApplicationController
  before_action :set_ficha, only: %i[ show edit update destroy ]
  after_action :destroi_conteudo_se_tipo_alterado, only: %i[ update ]

  # GET /fichas or /fichas.json
  def index
    @fichas = Ficha.order('created_at desc')
  end

  # GET /fichas/1 or /fichas/1.json
  def show
  end

  # GET /fichas/new
  def new
    @ficha = Ficha.new(tipo: params[:tipo])
  end

  # GET /fichas/1/edit
  def edit
  end

  # POST /fichas or /fichas.json
  def create
    @ficha = Ficha.new(ficha_params)

    respond_to do |format|
      if @ficha.save
        format.html { refresh_or_redirect_to ficha_url(@ficha), notice: "Ficha foi atualizado com sucesso." }
        format.json { render :show, status: :created, location: @ficha }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ficha.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fichas/1 or /fichas/1.json
  def update
    respond_to do |format|
      if @ficha.update(ficha_params)
        format.html { refresh_or_redirect_to ficha_url(@ficha), notice: "Ficha foi atualizado com sucesso." }
        format.json { render :show, status: :ok, location: @ficha }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ficha.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fichas/1 or /fichas/1.json
  def destroy
    @ficha.destroy

    respond_to do |format|
      format.html { recede_or_redirect_to fichas_url, notice: "A #{@ficha.nome} foi destruida com sucesso." }
      format.json { head :no_content }
    end
  end

  def show_ficha_diets
    @fichas = Ficha.where(tipo: 'dieta').order('created_at desc')
  end

  def show_ficha_treinos
    @fichas = Ficha.where(tipo: 'treino').order('created_at desc')
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_ficha
      @ficha = Ficha.find(params[:id])
    end

    def destroi_conteudo_se_tipo_alterado
      if @ficha.tipo == 'treino' && @ficha.dietas.exists?
        @ficha.dietas.destroy_all
      end

      if @ficha.tipo == 'dieta' && @ficha.treinos.exists?
        @ficha.treinos.destroy_all
      end
    end

    # Only allow a list of trusted parameters through.
    def ficha_params
      params.require(:ficha).permit(:nome, :tipo, :descricao)
    end
end
