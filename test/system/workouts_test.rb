require "application_system_test_case"

class WorkoutsTest < ApplicationSystemTestCase
  setup do
    sign_in_as(users(:lazaro_nixon))
    @workout = workouts(:one)
    @sheet = sheets(:one)
  end

  test "visiting the index" do
    visit sheet_workouts_url(@sheet)
    assert_selector "h1", text: @sheet.name
  end

  test "should create workout" do
    visit new_sheet_workout_path(@sheet)

    fill_in "Exercise", with: "Push ups"
    fill_in "Repetitions", with: "12"
    fill_in "Series", with: "3"
    fill_in "Interval", with: "30 seconds"

    select "low", from: "Charge"

    click_on "Save"

    assert_text "Workout was successfully created"
  end


  test "should update Workout" do
    visit sheet_workout_url(@sheet, @workout)
    click_on "Edit", match: :first

    fill_in "Exercise", with: @workout.exercise
    fill_in "Repetitions", with: @workout.repetitions
    fill_in "Series", with: @workout.series

    select "low", from: "Charge"

    click_on "Save"

    assert_text "Workout was successfully updated"
  end

  test "should destroy Workout" do
    visit sheet_workout_url(@sheet, @workout)
    click_on "Destroy"

    assert_selector "dialog[open]", visible: true

    within "dialog[open]" do
      click_on "Confirm"
    end

    assert_text "Workout was successfully destroyed"
  end
end
