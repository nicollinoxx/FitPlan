class SheetsController < ApplicationController
  before_action :set_sheet, only: %i[ show edit update destroy ]
  after_action :destroy_content_if_sheet_type_was_changed, only: %i[ update ]

  # GET /sheets or /sheets.json
  def index
    @sheets = Sheet.all
  end

  # GET /sheets/1 or /sheets/1.json
  def show
  end

  # GET /sheets/new
  def new
    @sheet = Sheet.new
  end

  # GET /sheets/1/edit
  def edit
  end

  # POST /sheets or /sheets.json
  def create
    @sheet = Sheet.new(sheet_params)

    if @sheet.save
      refresh_or_redirect_to sheet_url(@sheet), notice: "Sheet was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sheets/1 or /sheets/1.json
  def update
    if @sheet.update(sheet_params)
      refresh_or_redirect_to sheet_url(@sheet), notice: "Sheet was successfully updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  # DELETE /sheets/1 or /sheets/1.json
  def destroy
    @sheet.destroy!

    recede_or_redirect_to sheets_url, notice: "Sheet was successfully destroyed."
  end


  def sheet_diets_index
    @sheets = Sheet.where(sheet_type: 'diet')
    render :index
  end

  def sheet_workouts_index
    @sheets = Sheet.where(sheet_type: 'workout')
    render :index
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sheet
      @sheet = Sheet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sheet_params
      params.require(:sheet).permit(:name, :description, :sheet_type)
    end

    def filter_sheets_by_type
      if params[:sheet_type].present? && ['diet', 'workout'].include?(params[:sheet_type])
        @sheets = Sheet.where(sheet_type: params[:sheet_type])
      else
        @sheets = Sheet.all
      end
    end

    def destroy_content_if_sheet_type_was_changed
      if @sheet.sheet_type == 'workout' && @sheet.diets.exists?
        @sheet.diets.destroy_all
      end

      if @sheet.sheet_type == 'diet' && @sheet.workout.exists?
        @sheet.workout.destroy_all
      end
    end
end
