class WorkoutsController < ApplicationController
  include SheetScoped
  before_action :set_workout, only: %i[ show edit update destroy ]
  before_action :redirect_if_sheet_type_is_same_as_diet

  def index
    @workouts = @sheet.workouts
  end

  def show
  end

  def new
    @workout = @sheet.workouts.build
  end

  def edit
  end

  def create
    @workout = @sheet.workouts.build(workout_params)

    if @workout.save!
      refresh_or_redirect_to sheet_workout_url(@sheet, @workout), notice: I18n.t('notice.workout.create')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @workout.update(workout_params)
      refresh_or_redirect_to sheet_workout_url(@sheet, @workout), notice: I18n.t('notice.workout.update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @workout.destroy!
    recede_or_redirect_to sheet_workouts_url(@sheet), notice: I18n.t('notice.workout.destroy')
  end

  private

    def set_workout
      @workout =  @sheet.workouts.find(params[:id])
    end

    def workout_params
      params.require(:workout).permit(:exercise, :series, :repetitions, :charge, :interval, :video)
    end

    def redirect_if_sheet_type_is_same_as_diet
      redirect_to sheet_diets_path(@sheet) if @sheet.diet?
    end
end
