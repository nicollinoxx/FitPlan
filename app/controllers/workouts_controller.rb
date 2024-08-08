class WorkoutsController < ApplicationController
  include SheetScoped
  before_action :set_workout, only: %i[ show edit update destroy ]
  before_action :redirect_if_sheet_type_is_same_as_diet

  # GET /workouts or /workouts.json
  def index
    @workouts = @sheet.workouts
  end

  # GET /workouts/1 or /workouts/1.json
  def show
  end

  # GET /workouts/new
  def new
    @workout = @sheet.workouts.build
  end

  # GET /workouts/1/edit
  def edit
  end

  # POST /workouts or /workouts.json
  def create
    @workout = @sheet.workouts.build(workout_params)

    if @workout.save
      refresh_or_redirect_to sheet_workout_url(@sheet, @workout), notice: I18n.t('workouts.create.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /workouts/1 or /workouts/1.json
  def update
    if @workout.update(workout_params)
      refresh_or_redirect_to sheet_workout_url(@sheet, @workout), notice: I18n.t('workouts.update.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /workouts/1 or /workouts/1.json
  def destroy
    @workout.destroy!

    recede_or_redirect_to sheet_workouts_url(@sheet), notice: I18n.t('workouts.destroy.success')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workout
      @workout =  @sheet.workouts.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def workout_params
      params.require(:workout).permit(:exercise, :series, :repetitions, :charge, :interval, :video)
    end

    def redirect_if_sheet_type_is_same_as_diet
      if @sheet.sheet_type == 'diet'
        redirect_to sheet_diets_path(@sheet)
      end
    end
end
