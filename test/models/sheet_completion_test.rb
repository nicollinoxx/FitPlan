require "test_helper"

class SheetCompletionTest < ActiveSupport::TestCase
  setup do
    @user = users(:lazaro_nixon)
    travel_to Time.zone.local(2026, 3, 29, 12, 0, 0)
  end

  teardown do
    travel_back
  end

  test "streak should count consecutive days from today" do
    @user.sheet_completions.destroy_all
    @user.sheet_completions.create!(sheet: sheets(:one), completed_at: Time.current)
    @user.sheet_completions.create!(sheet: sheets(:one), completed_at: 1.day.ago)

    assert_equal 2, @user.sheet_completions.streak
  end

  test "streak should be zero with no completions today" do
    @user.sheet_completions.destroy_all
    assert_equal 0, @user.sheet_completions.streak
  end

  test "best_weekday should return day index" do
    result = @user.sheet_completions.best_weekday
    assert_includes (0..6), result
  end

  test "best_weekday should return nil with no completions" do
    @user.sheet_completions.destroy_all
    assert_nil @user.sheet_completions.best_weekday
  end

  test "weekly_progress should return this_week last_week and percentage" do
    progress = @user.sheet_completions.weekly_progress

    assert progress.key?(:this_week)
    assert progress.key?(:last_week)
    assert progress.key?(:percentage)
  end

  test "weekly_progress percentage should be 100 when last_week is zero" do
    @user.sheet_completions.destroy_all
    progress = @user.sheet_completions.weekly_progress

    assert_equal 100, progress[:percentage]
  end
end
