class SheetsController < ApplicationController
  before_action :set_user
  before_action :set_sheet, only: %i[ show edit update destroy ]

  # GET /sheets or /sheets.json
  def index
    @sheets = @user.sheets.search_by_type(params[:type])

    set_page_and_extract_portion_from @sheets.order(created_at: :desc)
    sleep 2.seconds unless @page.first?
  end

  # GET /sheets/1 or /sheets/1.json
  def show
    @users = User.search_by_name(params[:name], @user.id) if params[:name].present?
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
      refresh_or_redirect_to sheet_url(@sheet), notice: I18n.t('notice.sheet.create')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sheets/1 or /sheets/1.json
  def update
    if @sheet.update(sheet_params)
      refresh_or_redirect_to sheet_url(@sheet), notice: I18n.t('notice.sheet.update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /sheets/1 or /sheets/1.json
  def destroy
    @sheet.destroy
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
