module Workouts
  class CompletionsController < ApplicationController
    include SheetScoped
    before_action :set_workout

    def create
      @completion = @sheet.completions.create!(workout: @workout)
      refresh_or_redirect_to sheet_workouts_url(@sheet), notice: congratulations_notice
    end

    def destroy
      @sheet.completions.current_round(@sheet).find_by!(workout: @workout).destroy!
      refresh_or_redirect_to sheet_workouts_url(@sheet)
    end

    private

      def set_workout
        @workout = @sheet.workouts.find(params[:workout_id])
      end

      def congratulations_notice
        t('notice.sheet_completion.create') if @completion.sheet_completed?
      end
  end
end
