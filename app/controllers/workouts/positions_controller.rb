module Workouts
  class PositionsController < ApplicationController
    include SheetScoped
    before_action :set_workout

    def update
      @workout.update!(workout_params)
    end

    private

      def set_workout
        @workout = @sheet.workouts.find(params[:workout_id])
      end

      def workout_params
        params.expect(workout: [ :position ])
      end
  end
end
