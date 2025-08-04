class DietsController < ApplicationController
  include SheetScoped
  before_action :set_diet, only: %i[ show edit update destroy ]
  before_action :redirect_if_sheet_type_is_same_as_workout

  def index
    @diets = @sheet.diets
  end

  def show
    @percentage = @diet.percentage_of_calories
  end

  def new
    @diet = @sheet.diets.build
  end

  def edit
  end

  def create
    @diet = @sheet.diets.build(diet_params)

    if @diet.save
      refresh_or_redirect_to sheet_diet_url(@sheet, @diet), notice: I18n.t('notice.diet.create')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @diet.update(diet_params)
      refresh_or_redirect_to sheet_diet_url(@sheet, @diet), notice: I18n.t('notice.diet.update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @diet.destroy!

    recede_or_redirect_to sheet_diets_url(@sheet), notice: I18n.t('notice.diet.destroy')
  end

  private

    def set_diet
      @diet = @sheet.diets.find(params[:id])
    end

    def diet_params
      params.require(:diet).permit(:meal, :description, :protein_g, :carbohydrate_g, :fat_g, :calories)
    end

    def redirect_if_sheet_type_is_same_as_workout
      redirect_to sheet_workouts_path(@sheet) if @sheet.workout?
    end
end
