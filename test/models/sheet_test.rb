require "test_helper"

class SheetTest < ActiveSupport::TestCase
  setup do
    @workout_sheet = sheets(:one)
    @diet_sheet = sheets(:two)
    @empty_workout_sheet = sheets(:empty_workout)
    @empty_diet_sheet = sheets(:empty_diet)
  end

  test "should destroy workouts when changing sheet_type to diet" do
    @workout_sheet.update!(sheet_type: :diet)

    assert_empty @workout_sheet.workouts.reload
  end

  test "should destroy diets when changing sheet_type to workout" do
    @diet_sheet.update!(sheet_type: :workout)

    assert_empty @diet_sheet.diets.reload
  end

  test "completed? should be true with a completion today" do
    assert_not @workout_sheet.completed?
    @workout_sheet.complete!
    assert @workout_sheet.completed?
  end

  test "complete! should create a sheet completion for workout" do
    assert_difference "SheetCompletion.count", 1 do
      @workout_sheet.complete!
    end
  end

  test "complete! should allow multiple workout rounds in the same day" do
    @workout_sheet.complete!

    assert_difference "SheetCompletion.count", 1 do
      @workout_sheet.complete!
    end
  end

  test "complete! should create only a sheet completion for diet" do
    assert_no_difference "Completion.count" do
      assert_difference "SheetCompletion.count", 1 do
        @diet_sheet.complete!
      end
    end
  end

  test "complete! should allow multiple diet rounds in the same day" do
    @diet_sheet.complete!

    assert_difference "SheetCompletion.count", 1 do
      assert_no_difference "Completion.count" do
        @diet_sheet.complete!
      end
    end
  end

  test "complete! should associate pending completions" do
    completion = completions(:fixture_workout_pending)

    @empty_workout_sheet.complete!

    assert_not_nil completion.reload.sheet_completion_id
    assert_equal @empty_workout_sheet.sheet_completions_today.last.id, completion.sheet_completion_id
  end

  test "uncomplete! should destroy the latest completion and its items" do
    completion = completions(:fixture_diet_pending)
    @empty_diet_sheet.complete!

    assert_difference "SheetCompletion.count", -1 do
      assert_difference "Completion.count", -1 do
        @empty_diet_sheet.uncomplete!
      end
    end

    assert_raises(ActiveRecord::RecordNotFound) { completion.reload }
  end

  test "uncomplete! should do nothing without a completion today" do
    assert_no_difference "SheetCompletion.count" do
      @workout_sheet.uncomplete!
    end
  end
end
