class Diets::GenerationsController < ApplicationController
  include SheetScoped

  def create
    @sheet.add_recommended!(diets_params)
    render json: { location: sheet_diets_path(@sheet) }, status: :created
  end

  private

    def diets_params
      params.expect(diets: [ [ :meal, :description, :protein_g, :carbohydrate_g, :fat_g ] ])
    end
end
