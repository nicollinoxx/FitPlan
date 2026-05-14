class Sheets::RequestsController < ApplicationController
  before_action :set_request
  before_action :set_sheet_share, only: %i[update destroy]

  def update
    @request.accepted!
    CopySheetJob.perform_later(@request)

    turbo_respond @sheet_share.sheet_requests.reload.pending.none?
  end

  def destroy
    @request.destroy!
    turbo_respond @sheet_share.destroyed?
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

    def turbo_respond(redirect)
      return redirect_to sheets_shares_path(filter: params[:filter], format: :html) if redirect
      render turbo_stream: turbo_stream.remove(@request)
    end
end
