require "test_helper"

class Workouts::PositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
  end

  test "moves the workout to the given position" do
    patch sheet_workout_position_url(sheets(:one), workouts(:fixture_workout)), params: { workout: { position: 1 } }, as: :json

    assert_response :no_content
    assert_equal 1, workouts(:fixture_workout).reload.position
    assert_equal 2, workouts(:one).reload.position
  end
end
