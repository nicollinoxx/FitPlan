class DashboardController < ApplicationController
  before_action :set_user, :set_completions

  def index
    @healthy_metric = @user.healthy_metric

    @diets_calories        = diet_calories_by_sheet
    @total_diet_calories   = total_diet_calories
    @average_diet_calories = average_diet_calories

    @completions_by_type     = completions_by_type
    @completions_by_sheet    = completions_by_sheet
    @total_completions_today = @completions.today.count
    @total_completions       = @completions.count
    @streak                  = @completions.streak
    @best_day                = @completions.best_weekday
    @weekly_progress         = @completions.weekly_progress
  end

  private

  def sheets_with_diets
    @sheets_with_diets ||= @user.sheets.diet.joins(:diets)
  end

  def diet_calories_by_sheet
    sheets_with_diets.group('sheets.name').sum('diets.calories')
  end

  def total_diet_calories
    sheets_with_diets.sum('diets.calories')&.round(2) || 0
  end

  def average_diet_calories
    sheets_with_diets.average('diets.calories')&.round(2) || 0
  end

  def completions_by_type
    [
      { name: "Workout", data: @completions.joins(:sheet).merge(Sheet.workout).grouped_by(params[:period]) },
      { name: "Diet",    data: @completions.joins(:sheet).merge(Sheet.diet).grouped_by(params[:period]) }
    ]
  end

  def completions_by_sheet
    @completions.joins(:sheet).group('sheets.name').count
  end

  def set_user
    @user = Current.user
  end

  def set_completions
    @completions = @user.sheet_completions
  end
end
