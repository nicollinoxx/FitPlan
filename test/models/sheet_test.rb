require "test_helper"

class SheetTest < ActiveSupport::TestCase
  setup do
    @workout_sheet       = sheets(:one)
    @diet_sheet          = sheets(:two)
    @empty_workout_sheet = sheets(:empty_workout)
    @empty_diet_sheet    = sheets(:empty_diet)
  end

  test "should be invalid without a name" do
    sheet = Sheet.new(sheet_type: :workout, user: @workout_sheet.user)
    assert_not sheet.valid?
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

  test "with_content includes sheets with workouts or diets and excludes empty ones" do
    assert_includes Sheet.with_content, @workout_sheet
    assert_includes Sheet.with_content, @diet_sheet
    assert_not_includes Sheet.with_content, @empty_workout_sheet
    assert_not_includes Sheet.with_content, @empty_diet_sheet
  end

  test "generate_from_recommendation! creates suggested sheets with their items on top of the list" do
    user = users(:lazaro_nixon)

    sheets = user.sheets.generate_from_recommendation!([
      { name: "Legs", description: "Lower body", sheet_type: "workout", workouts: [ { exercise: "Squat", series: 4, repetitions: "8", interval: 90, charge: "high" } ] },
      { name: "Bulk", description: "More protein", sheet_type: "diet", diets: [ { meal: "Breakfast", description: "Eggs", protein_g: 30, carbohydrate_g: 40, fat_g: 10 } ] }
    ])

    assert_equal [ "Legs", "Bulk" ], user.sheets.positioned.first(2).map(&:name)
    assert sheets.all?(&:suggested?)
    assert_equal [ "Squat" ], sheets.first.workouts.pluck(:exercise)
    assert_equal 370, sheets.last.diets.first.calories
  end

  test "generate_from_recommendation! saves nothing when an item is invalid" do
    assert_no_difference "Sheet.count" do
      assert_raises(ActiveRecord::RecordInvalid) do
        users(:lazaro_nixon).sheets.generate_from_recommendation!([ { name: "Legs", sheet_type: "workout", workouts: [ { exercise: "" } ] } ])
      end
    end
  end

  test "add_recommended! adds items of the sheet's own type at the end" do
    @workout_sheet.add_recommended!([ { exercise: "Lunge", series: 3, repetitions: "12" } ])

    assert_equal "Lunge", @workout_sheet.workouts.positioned.last.exercise
  end

  test "origin tells copied, suggested and hand made sheets apart" do
    assert_equal :manual, @workout_sheet.origin
    assert_equal :suggested, Sheet.new(suggested: true).origin
    assert_equal :copied, Sheet.new(copy: true, suggested: true).origin
  end

  test "improve_recommended! updates only the sheet's own items, all or nothing" do
    workout = workouts(:one)

    @workout_sheet.improve_recommended!([ { id: workout.id, series: 5, charge: "high" } ])
    assert_equal [ 5, "high" ], workout.reload.values_at(:series, :charge)

    assert_raises(ActiveRecord::RecordNotFound) { @workout_sheet.improve_recommended!([ { id: workout.id, series: 6 }, { id: workouts(:two).id, series: 2 } ]) }
    assert_equal 5, workout.reload.series
  end
end
