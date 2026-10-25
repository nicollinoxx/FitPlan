require "test_helper"

class Workouts::GenerationsControllerTest < ActionDispatch::IntegrationTest
  test "adds the suggested workouts to an existing sheet" do
    sign_in_as(users(:lazaro_nixon))

    post sheet_workouts_generation_url(sheets(:one)), as: :json, params: { workouts: [ { exercise: "Lunge", series: 3, repetitions: "12" } ] }

    assert_response :created
    assert_equal sheet_workouts_path(sheets(:one)), response.parsed_body["location"]
    assert_equal "Lunge", sheets(:one).workouts.positioned.last.exercise
  end

  test "cannot add to someone else's sheet" do
    sign_in_as(users(:lazaro))

    assert_no_difference "Workout.count" do
      post sheet_workouts_generation_url(sheets(:one)), as: :json, params: { workouts: [ { exercise: "Lunge", series: 3, repetitions: "12" } ] }
    end

    assert_response :not_found
  end

  test "applies the suggested changes to the existing workouts" do
    sign_in_as(users(:lazaro_nixon))
    item = workouts(:one)

    patch sheet_workouts_generation_url(sheets(:one)), as: :json, params: { workouts: [ { id: item.id, series: 5 } ] }

    assert_response :success
    assert_equal "5", item.reload.series.to_s
  end
end
