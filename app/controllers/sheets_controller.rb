class SheetsController < ApplicationController
  before_action :set_user
  before_action :set_sheet, only: %i[ show edit update destroy ]
  after_action :destroy_content_if_sheet_type_was_changed, only: %i[ update ]

  # GET /sheets or /sheets.json
  def index
    @sheets = @user.sheets
  end

  # GET /sheets/1 or /sheets/1.json
  def show
  end

  # GET /sheets/new
  def new
    @sheet = @user.sheets.new
  end

  # GET /sheets/1/edit
  def edit
  end

  # POST /sheets or /sheets.json
  def create
    @sheet = @user.sheets.new(sheet_params)

    if @sheet.save
      refresh_or_redirect_to sheet_url(@sheet), notice: I18n.t('sheets.create.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sheets/1 or /sheets/1.json
  def update
    if @sheet.update(sheet_params)
      refresh_or_redirect_to sheet_url(@sheet), notice: I18n.t('sheets.update.success')
    else
      render :show, status: :unprocessable_entity
    end
  end

  # DELETE /sheets/1 or /sheets/1.json
  def destroy
    @sheet.destroy!

    recede_or_redirect_to sheets_url, notice: I18n.t('sheets.destroy.success')
  end

  #filter sheets by type and adds specific title for filtered content
  def sheet_diets_index
    @sheets = @user.sheets.where(sheet_type: 'diet')
    @title = '.sheets_diet_title'
    render :index
  end

  def sheet_workouts_index
    @sheets = @user.sheets.where(sheet_type: 'workout')
    @title = '.sheets_workout_title'
    render :index
  end

  private
    def set_user
      @user = Current.user if Current.user.present?
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_sheet
      @sheet = @user.sheets.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sheet_params
      params.require(:sheet).permit(:name, :description, :sheet_type)
    end

    def destroy_content_if_sheet_type_was_changed
      if @sheet.sheet_type == 'workout' && @sheet.diets.exists?
        @sheet.diets.destroy_all
      end

      if @sheet.sheet_type == 'diet' && @sheet.workouts.exists?
        @sheet.workout.destroy_all
      end
    end
end
