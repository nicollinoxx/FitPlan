require "test_helper"

class Workouts::CompletionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
    @sheet = sheets(:one)
    @workout = workouts(:one)
  end

  test "should create completion" do
    assert_difference("Completion.count") do
      post sheet_workout_completion_url(@sheet, @workout)
    end

    assert_redirected_to sheet_workouts_url(@sheet, pulsed: @workout.id)
  end

  test "should destroy completion" do
    @sheet.completions.create!(workout: @workout)

    assert_difference("Completion.count", -1) do
      delete sheet_workout_completion_url(@sheet, @workout)
    end

    assert_redirected_to sheet_workouts_url(@sheet)
  end

  test "should create sheet_completion when all workouts decremented to zero" do
    assert_difference("SheetCompletion.count", 1) do
      @sheet.workouts.each do |workout|
        workout.series.times { post sheet_workout_completion_url(@sheet, workout) }
      end
    end
  end

  test "workout completion uses server time despite client timestamps" do
    travel_to Time.zone.local(2026, 9, 30, 23, 30) do
      post sheet_workout_completion_url(@sheet, @workout), params: {
        completed_at: 1.month.from_now, remaining_series: 0,
        completion: { completed_at: 1.month.ago, created_at: 1.month.ago }
      }

      assert_response :redirect
      completion = @sheet.completions.today.find_by!(workout: @workout)
      assert_equal Time.current, completion.completed_at
      assert_equal @workout.series - 1, completion.remaining_series
    end
  end
end
