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

  test "should create sheet_completion when all items are completed" do
    assert_difference("SheetCompletion.count") do
      @sheet.workouts.each { |w| @sheet.completions.create!(workout: w) }
    end
  end

  test "should not create sheet_completion when not all items are completed" do
    assert_no_difference("SheetCompletion.count") do
      @sheet.completions.create!(workout: @workout)
    end
  end

  test "current_round should be empty after completing all items" do
    @sheet.workouts.each { |w| @sheet.completions.create!(workout: w) }

    assert_empty @sheet.completions.current_round(@sheet)
  end

  test "current_round should include completions when no rounds exist" do
    completion = @sheet.completions.create!(workout: @workout)

    assert_includes @sheet.completions.current_round(@sheet), completion
  end
end
