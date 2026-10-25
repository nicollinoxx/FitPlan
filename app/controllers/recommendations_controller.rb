class RecommendationsController < ApplicationController
  before_action :set_sheet

  def new
    @free_models = OpenRouter::FreeModels.all if Current.user.open_router_connected?
  end

  def create
    Current.user.update!(open_router_model: recommendation_params[:model])
    RecommendationJob.perform_later(Current.user, params.expect(:token), answers, @sheet)

    head :accepted
  end

  private

    def set_sheet
      @sheet = Current.user.sheets.find(params[:sheet_id]) if params[:sheet_id].present?
    end

    def recommendation_params
      params.expect(recommendation: [ :kind, :mode, :split, :goal, :activity_level, :dietary_preference, :notes, :model ])
    end

    def answers
      recommendation_params.slice(:kind, :mode, :split, :goal, :activity_level, :dietary_preference, :notes).to_h
    end
end
