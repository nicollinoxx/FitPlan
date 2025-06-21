class Sheets::CopiesController < ApplicationController
  include SheetScoped
  before_action :set_user, :copy_sheet, only: [:create]

  def create
    if @copy_sheet.save
      Sheets::CopySheetContentJob.perform_later(@sheet.id, @copy_sheet.id)
    else
      refresh_or_redirect_to sheet_path(@sheet), notice: "Failed to copy sheet."
    end
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def copy_sheet
      @copy_sheet = @user.sheets.build(copy_sheet_params)
    end

    def copy_sheet_params
      @sheet.attributes.except("id", "created_at", "updated_at").merge(copy: true)
    end
end
