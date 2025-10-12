# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :set_user

  def index
    @healthy_metric = Current.user.healthy_metric

    @sheets = sheets_by_type

    @diets_calories = diet_calories_by_sheet
    @total_diet_calories = total_diet_calories
    @average_diet_calories = average_diet_calories
  end

  private

  def sheets_by_type
    [
      { name: "Workout", data: @user.sheets.workout.grouped_by(params[:period]) },
      { name: "Diet",    data: @user.sheets.diet.grouped_by(params[:period]) }
    ]
  end

  def sheets_with_diets
    @sheets_with_diets ||= @user.sheets.diet.joins(:diets)
  end

  def diet_calories_by_sheet
    sheets_with_diets.group('sheets.id', 'sheets.name').pluck('sheets.name, SUM(diets.calories)')
  end

  def total_diet_calories
    sheets_with_diets.sum('diets.calories')&.round(2) || 0
  end

  def average_diet_calories
    sheets_with_diets.average('diets.calories')&.round(2) || 0
  end

  def set_user
    @user = Current.user
  end
end
