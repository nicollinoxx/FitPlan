class DietsController < ApplicationController
  before_action :set_diet, only: %i[ show edit update destroy ]

  # GET /diets or /diets.json
  def index
    @diets = Diet.all
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
    @diet = Diet.new(diet_params)

    respond_to do |format|
      if @diet.save
        format.html { refresh_or_redirect_to diet_url(@diet), notice: "Diet was successfully created." }
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
        format.html { refresh_or_redirect_to diet_url(@diet), notice: "Diet was successfully updated." }
        format.json { render :show, status: :ok, location: @diet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @diet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diets/1 or /diets/1.json
  def destroy
    @diet.destroy!

    respond_to do |format|
      format.html { recede_or_redirect_to diets_url, notice: "Diet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diet
      @diet = Diet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def diet_params
      params.require(:diet).permit(:snack, :description, :protein_g, :carbohydrate_g, :fat_g, :calories)
    end
end
