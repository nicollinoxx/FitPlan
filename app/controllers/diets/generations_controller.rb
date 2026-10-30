class Diets::GenerationsController < ApplicationController
  include SheetScoped

  def create
    @sheet.add_recommended!(diets_params)
    render json: { location: sheet_diets_path(@sheet) }, status: :created
  end

  def update
    @sheet.improve_recommended!(diet_changes_params)
    render json: { location: sheet_diets_path(@sheet) }
  end

  private

    def diets_params
      params.expect(diets: [ [ :meal, :description, :protein_g, :carbohydrate_g, :fat_g ] ])
    end

    def diet_changes_params
      params.expect(diets: [ [ :id, :meal, :description, :protein_g, :carbohydrate_g, :fat_g ] ])
    end
end
