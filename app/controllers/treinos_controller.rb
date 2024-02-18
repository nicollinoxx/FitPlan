class TreinosController < ApplicationController
  include FichaScoped

  before_action :set_treino, only: %i[ show edit update destroy ]

  # GET /treinos or /treinos.json
  def index
    @treinos = @ficha.treinos.all
  end

  # GET /treinos/1 or /treinos/1.json
  def show
  end

  # GET /treinos/1/edit
  def edit
  end

  def new
    @treino = Treino.new
  end

  # POST /treinos or /treinos.json
  def create
    @treino = @ficha.treinos.new(treino_params)

    respond_to do |format|
      if @treino.save
        format.html { refresh_or_redirect_to ficha_treino_url(@ficha, @treino), notice: "Treino foi criado com sucesso." }
        format.json { render :show, status: :created, location: @treino }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @treino.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /treinos/1 or /treinos/1.json
  def update
    respond_to do |format|
      if @treino.update(treino_params)
        format.html { recede_or_redirect_to ficha_treino_url(@ficha, @treino), notice: "Treino foi atualizado com sucesso." }
        format.json { render :show, status: :ok, location: @treino }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @treino.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /treinos/1 or /treinos/1.json
  def destroy
    @treino.destroy

    respond_to do |format|
      format.html { recede_or_redirect_to ficha_treinos_path(@ficha), notice: "Treino foi destruido com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_treino
      @treino = @ficha.treinos.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      recede_or_redirect_to fichas_url
    end

    # Only allow a list of trusted parameters through.
    def treino_params
      params.require(:treino).permit(:exercicio, :series, :repeticoes, :carga, :video)
    end
end
