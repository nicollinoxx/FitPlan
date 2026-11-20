class Sheets::GenerationsController < ApplicationController
  def create
    return head :conflict unless claim_generation_token

    sheets = Current.user.sheets.generate_from_recommendation!(sheets_params)
    render json: { location: sheets_path(suggested: sheets.map(&:id)) }, status: :created
  rescue StandardError
    release_generation_token
    raise
  end

  private

  def claim_generation_token
    return true if params[:token].blank?

    Rails.cache.write(generation_cache_key, true, unless_exist: true, expires_in: 1.hour)
  end

  def release_generation_token
    Rails.cache.delete(generation_cache_key) if params[:token].present?
  end

  def generation_cache_key
    "recommendation_generation:#{Current.user.id}:#{params[:token]}"
  end

  def sheets_params
    params.expect(sheets: [ [ :name, :description, :sheet_type,
                              workouts: [ [ :exercise, :series, :repetitions, :interval, :charge ] ],
                              diets:    [ [ :meal, :description, :protein_g, :carbohydrate_g, :fat_g ] ] ] ])
  end
end
