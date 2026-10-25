class Workouts::GenerationsController < ApplicationController
  include SheetScoped

  def create
    @sheet.add_recommended!(workouts_params)
    render json: { location: sheet_workouts_path(@sheet) }, status: :created
  end

  def update
    @sheet.improve_recommended!(workout_changes_params)
    render json: { location: sheet_workouts_path(@sheet) }
  end

  private

    def workouts_params
      params.expect(workouts: [ [ :exercise, :series, :repetitions, :interval, :charge ] ])
    end

    def workout_changes_params
      params.expect(workouts: [ [ :id, :exercise, :series, :repetitions, :interval, :charge ] ])
    end
end
