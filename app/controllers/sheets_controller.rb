class SheetsController < ApplicationController
  before_action :set_user
  before_action :set_sheet, only: %i[ show edit update destroy ]

  def index
    @sheets = @user.sheets.search_by_type(params[:type])

    set_page_and_extract_portion_from @sheets.order(created_at: :desc)
    sleep 2.seconds unless @page.first?
  end

  def show
  end

  def new
    @sheet = @user.sheets.build
  end

  def edit
  end

  def create
    @sheet = @user.sheets.build(sheet_params)

    if @sheet.save
      refresh_or_redirect_to sheet_url(@sheet), notice: I18n.t('notice.sheet.create')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @sheet.update(sheet_params)
      refresh_or_redirect_to sheet_url(@sheet), notice: I18n.t('notice.sheet.update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sheet.destroy!; flash[:notice] = I18n.t('notice.sheet.destroy')
  end

  private
    def set_user
      @user = Current.user if Current.user.present?
    end

    def set_sheet
      @sheet = @user.sheets.find(params[:id])
    end

    def sheet_params
      params.require(:sheet).permit(:name, :description, :sheet_type, :visibility)
    end
end
