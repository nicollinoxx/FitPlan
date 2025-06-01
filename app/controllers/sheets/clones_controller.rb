class Sheets::ClonesController < ApplicationController
  before_action :set_sheet, :set_user

  def create
    Sheets::CreateSheetCloneJob.perform_later(@sheet, @user)
  end

  private

  def set_sheet
    @sheet = Sheet.find(params[:sheet_id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end
end
