class Workouts::VideosController < ApplicationController
  include SheetScoped
  before_action :set_workout

  def destroy
    @workout.video.purge_later
    render turbo_stream: turbo_stream.remove('video')
  end

  private

  def set_workout
    @workout = @sheet.workouts.find(params[:workout_id])
  end
end
