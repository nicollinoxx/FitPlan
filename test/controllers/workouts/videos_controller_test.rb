require "test_helper"

class Workouts::VideosControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    sign_in_as(users(:lazaro_nixon))
    @sheet   = sheets(:one)
    @workout = workouts(:one)
    @workout.video.attach(io: file_fixture("sample_video.mp4").open, filename: "sample_video.mp4", content_type: "video/mp4")
  end

  test "should purge the video and remove it from the page" do
    perform_enqueued_jobs do
      delete sheet_workout_video_url(@sheet, @workout, @workout.video), as: :turbo_stream
    end

    assert_response :success
    assert_match '<turbo-stream action="remove" target="video">', response.body
    assert_not @workout.reload.video.attached?
  end
end
