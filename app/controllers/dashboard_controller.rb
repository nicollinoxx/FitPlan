# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
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
      { name: "Workout", data: grouped_sheets(Current.user.sheets.workout) },
      { name: "Diet",    data: grouped_sheets(Current.user.sheets.diet) }
    ]
  end

  def grouped_sheets(sheets)
    case params[:period].to_s
    when "day"
      sheets.group_by_day(:created_at).count
    when "week"
      sheets.group_by_week(:created_at).count
    when "year"
      sheets.group_by_year(:created_at).count
    else
      sheets.group_by_month(:created_at).count
    end
  end

  def diet_calories_by_sheet
    sheets_with_diets.group('sheets.id, sheets.name').pluck('sheets.name, SUM(diets.calories)')
  end

  def total_diet_calories
    sheets_with_diets.sum('diets.calories')
  end

  def average_diet_calories
    sheets_with_diets.average('diets.calories')
  end

  def sheets_with_diets
    Current.user.sheets.diet.joins(:diets)
  end
end
