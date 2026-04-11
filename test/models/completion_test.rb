require "test_helper"

class CompletionTest < ActiveSupport::TestCase
  setup do
    @sheet = sheets(:one)
    @workout = workouts(:one)
  end

  test "should set completed_at automatically" do
    completion = @sheet.completions.create!(workout: @workout)
    assert_not_nil completion.completed_at
  end

  test "should be invalid without workout or diet" do
    completion = @sheet.completions.build
    assert_not completion.valid?
  end

  test "should set remaining_series from workout on create" do
    completion = @sheet.completions.create!(workout: workouts(:another))
    assert_equal workouts(:another).series, completion.remaining_series
  end

  test "should create sheet_completion when all workouts decremented to zero" do
    assert_difference("SheetCompletion.count", 1) do
      @sheet.workouts.each do |workout|
        completion = @sheet.completions.create!(workout: workout)
        workout.series.times { completion.decrement_series! }
      end
    end
  end

  test "should not create sheet_completion when not all items are completed" do
    assert_no_difference("SheetCompletion.count") do
      completion = @sheet.completions.create!(workout: @workout)
      completion.decrement_series!
    end
  end

  test "current_round should be empty after completing all items" do
    @sheet.workouts.each do |workout|
      completion = @sheet.completions.create!(workout: workout)
      workout.series.times { completion.decrement_series! }
    end

    assert_empty @sheet.completions.current_round
  end

  test "current_round should include completions with nil sheet_completion_id" do
    completion = @sheet.completions.create!(workout: @workout)
    assert_includes @sheet.completions.current_round, completion
  end

  test "current_round should exclude completions associated with a sheet_completion" do
    completion = @sheet.completions.create!(workout: @workout)
    @sheet.mark_sheet_completion!

    assert_not_includes @sheet.completions.current_round, completion.reload
    assert_not_nil completion.sheet_completion_id
  end
end
