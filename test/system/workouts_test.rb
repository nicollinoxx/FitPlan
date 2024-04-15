require "application_system_test_case"

class WorkoutsTest < ApplicationSystemTestCase
  setup do
    @workout = workouts(:one)
  end

  test "visiting the index" do
    visit workouts_url
    assert_selector "h1", text: "Workouts"
  end

  test "should create workout" do
    visit workouts_url
    click_on "New workout"

    fill_in "Charge", with: @workout.charge
    fill_in "Exercise", with: @workout.exercise
    fill_in "Repetitions", with: @workout.repetitions
    fill_in "Series", with: @workout.series
    click_on "Create Workout"

    assert_text "Workout was successfully created"
    click_on "Back"
  end

  test "should update Workout" do
    visit workout_url(@workout)
    click_on "Edit this workout", match: :first

    fill_in "Charge", with: @workout.charge
    fill_in "Exercise", with: @workout.exercise
    fill_in "Repetitions", with: @workout.repetitions
    fill_in "Series", with: @workout.series
    click_on "Update Workout"

    assert_text "Workout was successfully updated"
    click_on "Back"
  end

  test "should destroy Workout" do
    visit workout_url(@workout)
    click_on "Destroy this workout", match: :first

    assert_text "Workout was successfully destroyed"
  end
end
