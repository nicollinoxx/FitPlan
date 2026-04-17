module Workouts
  class CompletionsController < ApplicationController
    include SheetScoped
    before_action :set_workout

    def create
      @sheet.completions.current_round.find_or_create_by!(workout: @workout).decrement_series!
      redirect_to sheet_workouts_url(@sheet, pulsed: @workout.id)
    end

    def destroy
      @sheet.completions.current_round.find_by!(workout: @workout).destroy!
      redirect_to sheet_workouts_url(@sheet)
    end

    private

      def set_workout
        @workout = @sheet.workouts.find(params[:workout_id])
      end
  end
end
