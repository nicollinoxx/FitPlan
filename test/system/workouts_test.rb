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
    visit new_sheet_workout_url(@sheet)

    fill_in :workout_exercise, with: "Push ups"
    fill_in :workout_repetitions, with: "12"
    fill_in :workout_series, with: "3"
    fill_in :workout_interval, with: "30"
    select t("workouts.form.options_charge.low"), from: :workout_charge
    click_on t("save")

    assert_text t("notice.workout.create")
  end

  test "should update Workout" do
    visit sheet_workout_url(@sheet, @workout)
    click_on t("edit"), match: :first

    fill_in :workout_exercise, with: @workout.exercise
    fill_in :workout_repetitions, with: @workout.repetitions
    fill_in :workout_series, with: @workout.series
    select t("workouts.form.options_charge.low"), from: :workout_charge
    click_on t("save")

    assert_text t("notice.workout.update")
  end

  test "should destroy Workout" do
    visit sheet_workout_url(@sheet, @workout)
    click_on t("destroy"), match: :first
    confirm_dialog

    assert_text t("notice.workout.destroy")
  end
end
