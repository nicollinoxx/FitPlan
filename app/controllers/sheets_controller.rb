class SheetsController < ApplicationController
  before_action :set_user
  before_action :set_sheet, only: %i[ show edit update destroy ]

  # GET /sheets or /sheets.json
  def index
    @sheets = params[:type] ? @user.sheets.where(sheet_type: params[:type]) : @user.sheets 
  end

  # GET /sheets/1 or /sheets/1.json
  def show
  end

  # GET /sheets/new
  def new
    @sheet = @user.sheets.build
  end

  # GET /sheets/1/edit
  def edit
  end

  # POST /sheets or /sheets.json
  def create
    @sheet = @user.sheets.build(sheet_params)

    if @sheet.save
      redirect_to sheet_url(@sheet), notice: I18n.t('sheets.create.success')
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
end
