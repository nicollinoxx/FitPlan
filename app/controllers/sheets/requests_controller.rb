class Sheets::RequestsController < ApplicationController
  before_action :set_request
  before_action :set_sheet_share, only: [:update, :destroy]

  def update
    @request.accepted!
    render turbo_stream: turbo_stream.replace(@request, partial: "sheets/requests/request", locals: { request: @request })
  end

  def destroy
    @request.destroy!

    if @sheet_share.destroyed?
      recede_or_redirect_to sheets_shares_path(filter: params[:filter], format: :html)
    else
      render turbo_stream: turbo_stream.remove(@request)
    end
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
end
