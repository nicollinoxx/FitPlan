require "test_helper"

class SheetTest < ActiveSupport::TestCase
  setup do
    @workout_sheet = sheets(:one)
    @diet_sheet    = sheets(:two)
  end

  test "should destroy workouts when changing sheet_type to diet" do
    @workout_sheet.update!(sheet_type: :diet)

    assert_empty @workout_sheet.workouts.reload
  end

  test "should destroy diets when changing sheet_type to workout" do
    @diet_sheet.update!(sheet_type: :workout)

    assert_empty @diet_sheet.diets.reload
  end

  test "completed? returns true when sheet has a sheet_completion today" do
    assert_not @workout_sheet.completed?
    @workout_sheet.complete!
    assert @workout_sheet.completed?
  end

  test "complete! on workout sheet creates a sheet_completion directly" do
    assert_difference("SheetCompletion.count", 1) do
      @workout_sheet.complete!
    end
  end

  test "complete! on workout sheet supports multiple rounds per day" do
    @workout_sheet.complete!
    assert_difference("SheetCompletion.count", 1) do
      @workout_sheet.complete!
    end
  end

  test "complete! on diet sheet creates completions for missing diets and a sheet_completion" do
    assert_difference -> { Completion.count }, @diet_sheet.diets.count do
      assert_difference "SheetCompletion.count", 1 do
        @diet_sheet.complete!
      end
    end
  end

  test "complete! on diet sheet is idempotent when already completed" do
    @diet_sheet.complete!

    assert_no_difference "SheetCompletion.count" do
      assert_no_difference "Completion.count" do
        @diet_sheet.complete!
      end
    end
  end

  test "mark_sheet_completion! associates pending completions to the new sheet_completion" do
    completion = @workout_sheet.completions.create!(workout: workouts(:one))

    @workout_sheet.mark_sheet_completion!

    assert_not_nil completion.reload.sheet_completion_id
    assert_equal @workout_sheet.sheet_completions_today.last.id, completion.sheet_completion_id
  end

  test "uncomplete! destroys the latest sheet_completion and cascades to its completions" do
    @diet_sheet.complete!
    sc = @diet_sheet.sheet_completions_today.last
    associated = @diet_sheet.completions.where(sheet_completion_id: sc.id)

    assert associated.any?

    assert_difference "SheetCompletion.count", -1 do
      assert_difference "Completion.count", -associated.count do
        @diet_sheet.uncomplete!
      end
    end
  end

  test "uncomplete! is a no-op when sheet is not completed today" do
    assert_no_difference "SheetCompletion.count" do
      @workout_sheet.uncomplete!
    end
  end
end
