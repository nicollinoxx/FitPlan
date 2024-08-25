class Workouts::VideosController < ApplicationController
  before_action :set_workout

  def destroy
    @workout.video.purge_later

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove('video') }
    end
  end

  private

  def set_workout
    @workout = Workout.find(params[:workout_id])
  end
end
