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
    @workout = @sheet.workouts.new
  end

  # GET /workouts/1/edit
  def edit
  end

  # POST /workouts or /workouts.json
  def create
    @workout = @sheet.workouts.new(workout_params)

    respond_to do |format|
      if @workout.save
        format.html { refresh_or_redirect_to sheet_workout_url(@sheet, @workout), notice: "Workout was successfully created." }
        format.json { render :show, status: :created, location: @workout }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @workout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workouts/1 or /workouts/1.json
  def update
    respond_to do |format|
      if @workout.update(workout_params)
        format.html { refresh_or_redirect_to sheet_workout_url(@sheet, @workout), notice: "Workout was successfully updated." }
        format.json { render :show, status: :ok, location: @workout }
      else
        @workout.video.purge if @workout.errors.any?
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @workout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workouts/1 or /workouts/1.json
  def destroy
    @workout.destroy!

    respond_to do |format|
      format.html { recede_or_redirect_to sheet_workouts_url(@sheet), notice: "Workout was successfully destroyed." }
      format.json { head :no_content }
    end
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
