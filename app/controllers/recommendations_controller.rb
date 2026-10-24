class RecommendationsController < ApplicationController
  before_action :set_sheet

  def new
    @free_models = OpenRouter::FreeModels.all if Current.user.open_router_connected?
  end

  def create
    Current.user.update!(open_router_model: recommendation_params[:model])
    render json: open_router_recommendation.generate
  end

  private

    def set_sheet
      @sheet = Current.user.sheets.find(params[:sheet_id]) if params[:sheet_id].present?
    end

    def recommendation_params
      params.expect(recommendation: [ :kind, :goal, :activity_level, :dietary_preference, :notes, :model ])
    end

    def open_router_recommendation
      OpenRouter::Recommendation.new(Current.user, sheet: @sheet, answers: recommendation_params.slice(:kind, :goal, :activity_level, :dietary_preference, :notes).to_h)
    end
end
