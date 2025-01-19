class DietsController < ApplicationController
  include SheetScoped
  before_action :set_diet, only: %i[ show edit update destroy ]
  before_action :redirect_if_sheet_type_is_same_as_workout

  # GET /diets or /diets.json
  def index
    @diets = @sheet.diets
  end

  # GET /diets/1 or /diets/1.json
  def show
  end

  # GET /diets/new
  def new
    @diet = @sheet.diets.build
  end

  # GET /diets/1/edit
  def edit
  end

  # POST /diets or /diets.json
  def create
    @diet = @sheet.diets.build(diet_params)

    if @diet.save
      redirect_to sheet_diet_url(@sheet, @diet), notice: I18n.t('diets.create.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /diets/1 or /diets/1.json
  def update
    if @diet.update(diet_params)
      refresh_or_redirect_to sheet_diet_url(@sheet, @diet), notice: I18n.t('diets.update.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /diets/1 or /diets/1.json
  def destroy
    @diet.destroy!

    recede_or_redirect_to sheet_diets_url(@sheet), notice: I18n.t('diets.destroy.success')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diet
      @diet = @sheet.diets.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def diet_params
      params.require(:diet).permit(:meal, :description, :protein_g, :carbohydrate_g, :fat_g, :calories)
    end

    def redirect_if_sheet_type_is_same_as_workout
      if @sheet.workout?
        redirect_to sheet_workouts_path(@sheet)
      end
    end
end
