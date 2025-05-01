class Workouts::VideosController < ApplicationController
  before_action :set_workout

  def destroy
    @workout.video.purge

    render turbo_stream: turbo_stream.remove('video')
  end

  private

  def set_workout
    @workout = Workout.find(params[:workout_id])
  end
end
