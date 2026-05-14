class Sheets::RequestsController < ApplicationController
  before_action :set_request

  def preview_content
    @sheet = @request.sheet

    if @sheet.workout?
      @workouts = @sheet.workouts.order(created_at: :asc)
    else
      @diets = @sheet.diets.order(created_at: :asc)
    end
  end

  def update
    @request.accepted!
    CopySheetJob.perform_later(@request)
  end

  def destroy
    @request.destroy!
  end

  private

    def set_request
      @request = SheetRequest.accessible_by(Current.user).find(params[:id])
    end
end
