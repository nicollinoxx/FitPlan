class Sheets::GenerationsController < ApplicationController
  include RecommendationScoped

  def create
    @recommendation.accept! { Current.user.sheets.generate_from_recommendation!(sheets_params, recommendation: @recommendation) }
    render json: { location: sheets_path(suggested: @recommendation.generated_sheets.positioned.ids) }, status: :created
  end

  private

    def sheets_params
      params.expect(sheets: [ [ :name, :description, :sheet_type,
                                workouts: [ [ :exercise, :series, :repetitions, :interval, :charge ] ],
                                diets:    [ [ :meal, :description, :protein_g, :carbohydrate_g, :fat_g ] ] ] ])
    end
end
