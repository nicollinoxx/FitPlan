module Workouts
  class CompletionsController < ApplicationController
    include SheetScoped
    before_action :set_workout

    def create
      @sheet.completions.create!(user: Current.user, workout: @workout)
      refresh_or_redirect_to sheet_workouts_url(@sheet)
    end

    def destroy
      @sheet.completions.current_round(@sheet).find_by!(workout: @workout).destroy!
      refresh_or_redirect_to sheet_workouts_url(@sheet)
    end

    private

      def set_workout
        @workout = @sheet.workouts.find(params[:workout_id])
      end
  end
end
