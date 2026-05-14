class Sheets::RequestsController < ApplicationController
  before_action :set_request
  before_action :set_sheet_share, only: [:update, :destroy]

  def update
    @request.accepted!
    CopySheetJob.perform_later(@request)

    redirect_after_request
  end

  def destroy
    @request.destroy!
    redirect_after_request
  end

  def preview_content
    @sheet = @request.sheet
    @sheet.workout? ? workouts_content : diets_content
  end

  private

    def set_request
      @request = SheetRequest.accessible_by(Current.user).find(params[:id])
    end

    def set_sheet_share
      @sheet_share = @request.sheet_share
    end

    def workouts_content
      @workouts = @sheet.workouts.order(:created_at)
    end

    def diets_content
      @diets = @sheet.diets.order(:created_at)
    end

    def redirect_after_request
      if @sheet_share.sheet_requests.empty?
        redirect_to sheets_shares_path(filter: params[:filter], format: :html)
      else
        redirect_to sheets_share_path(@sheet_share, filter: params[:filter])
      end
    end
end
