class Sheets::GenerationsController < ApplicationController
  def create
    sheets = Current.user.sheets.generate_from_recommendation!(sheets_params)
    render json: { location: sheets_path(suggested: sheets.map(&:id)) }, status: :created
  end

  private

    def sheets_params
      params.expect(sheets: [ [ :name, :description, :sheet_type,
                                workouts: [ [ :exercise, :series, :repetitions, :interval, :charge ] ],
                                diets:    [ [ :meal, :description, :protein_g, :carbohydrate_g, :fat_g ] ] ] ])
    end
end
