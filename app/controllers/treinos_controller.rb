class TreinosController < ApplicationController
  before_action :set_treino, only: %i[ show edit update destroy ]

  # GET /treinos or /treinos.json
  def index
    @treinos = Treino.all
  end

  # GET /treinos/1 or /treinos/1.json
  def show
  end

  # GET /treinos/new
  def new
    @treino = Treino.new
    @action = 'Criar'
  end

  # GET /treinos/1/edit
  def edit
    @action = 'Editar'
  end

  # POST /treinos or /treinos.json
  def create
     @treino = Treino.new(treino_params)

    respond_to do |format|
      if @treino.save
        format.html { redirect_to treino_url(@treino), notice: "Treino was successfully created." }
        format.json { render :show, status: :created, location: @treino }
      else
        @action = 'Criar'
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @treino.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /treinos/1 or /treinos/1.json
  def update
    respond_to do |format|
      if @treino.update(treino_params)
        format.html { refresh_or_redirect_to treino_url(@treino), notice: "Treino was successfully updated." }
        format.json { render :show, status: :ok, location: @treino }
      else
        @action = 'Editar'
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @treino.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /treinos/1 or /treinos/1.json
  def destroy
    @treino.destroy

    respond_to do |format|
      format.html { redirect_to root_url, notice: "Treino was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_treino
      @treino = Treino.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def treino_params
      params.require(:treino).permit(:exercicio, :series, :repeticoes, :carga)
    end
end
