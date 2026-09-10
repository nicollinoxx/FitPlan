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

  test "refreshes the user ranking when a completion is destroyed" do
    @user.sheet_completions.destroy_all
    completion = @user.sheet_completions.create!(sheet: sheets(:one), completed_at: Time.current)

    assert_changes -> { @user.reload.ranking_score }, to: 0 do
      completion.destroy!
    end
  end

  test "destroying the user does not raise from the ranking callback" do
    user = User.create!(name: "Deleted", email: "deleted@example.com", password: "Secret1*3*5*")
    user.sheets.create!(name: "Sheet", sheet_type: "workout").sheet_completions.create!(user: user, completed_at: 1.day.ago)

    assert_nothing_raised { user.destroy! }
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

class SheetCompletionConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false
  self.fixture_table_names = []

  test "concurrent completions and refreshes preserve distinct day scoring" do
    travel_to Time.zone.local(2026, 9, 15, 12) do
      user = User.create!(name: "Concurrent", email: "concurrent-ranking@example.com", password: "Secret1*3*5*")
      sheet = user.sheets.create!(name: "Concurrent", sheet_type: "workout")
      ready = Queue.new
      start = Queue.new
      threads = [Time.current, 1.day.ago].map do |time|
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            ready << true
            start.pop
            2.times { SheetCompletion.create!(user_id: user.id, sheet_id: sheet.id, completed_at: time) }
          end
        end
      end
      2.times { ready.pop }
      2.times { start << true }
      threads.each(&:value)

      assert_equal 4, user.sheet_completions.count
      assert_equal 2, user.reload.current_streak
      assert_in_delta 6.67, user.ranking_score, 0.01
      user.refresh_ranking!
      assert_in_delta 6.67, user.reload.ranking_score, 0.01
    ensure
      threads&.each(&:join)
      user&.destroy!
    end
  end
end
