require "test_helper"

class WorkoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
    @workout = workouts(:one)
    @sheet = sheets(:one)
  end

  test "should get index" do
    get sheet_workouts_url(@sheet)
    assert_response :success
  end

  test "should get new" do
    get new_sheet_workout_url(@sheet, @workout)
    assert_response :success
  end

  test "should create workout" do
    assert_difference("Workout.count") do
      post sheet_workouts_url(@sheet), params: { workout: { charge: @workout.charge, exercise: @workout.exercise, repetitions: @workout.repetitions, series: @workout.series } }
    end

    assert_redirected_to sheet_workout_url(@sheet, Workout.last)
  end

  test "should show workout" do
    get sheet_workout_url(@sheet, @workout)
    assert_response :success
  end

  test "should get edit" do
    get edit_sheet_workout_url(@sheet, @workout)
    assert_response :success
  end

  test "should update workout" do
    patch sheet_workout_url(@sheet, @workout), params: { workout: { charge: @workout.charge, exercise: @workout.exercise, repetitions: @workout.repetitions, series: @workout.series } }
    assert_redirected_to sheet_workout_url(@sheet, @workout)
  end

  test "should destroy workout" do
    assert_difference("Workout.count", -1) do
      delete sheet_workout_url(@sheet, @workout)
    end

    assert_redirected_to sheet_workouts_url(@sheet)
  end
end
