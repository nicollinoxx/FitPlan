require "test_helper"

class User::RankableTest < ActiveSupport::TestCase
  setup do
    @user  = users(:lazaro_nixon)
    @other = users(:lazaro)
    travel_to Time.zone.local(2026, 9, 15, 12)
    @user.sheet_completions.destroy_all
    [1.day.ago, 2.days.ago].each do |time|
      @user.sheet_completions.create!(sheet: sheets(:one), completed_at: time)
    end
    @other.refresh_ranking!
  end

  # scoring ----------------------------

  test "refresh_ranking! scores consistency without an active streak" do
    @user.refresh_ranking!

    assert_equal 0, @user.current_streak
    assert_in_delta 4.67, @user.ranking_score, 0.01
  end

  test "refresh_ranking! rewards an active streak" do
    @user.sheet_completions.create!(sheet: sheets(:one), completed_at: Time.current)

    assert_equal 3, @user.reload.current_streak
    assert_in_delta 10.0, @user.ranking_score, 0.01
  end

  test "refresh_ranking! ignores completions outside the consistency window" do
    @user.sheet_completions.create!(sheet: sheets(:one), completed_at: 2.months.ago)
    @user.refresh_ranking!

    assert_in_delta 4.67, @user.ranking_score, 0.01
  end

  test "refresh_ranking! works for users with legacy invalid profile data" do
    @user.update_column(:handle, "legacy_handle")
    @user.update_column(:email, "legacy-without-an-at-sign")
    @user.reload.refresh_ranking!

    assert_in_delta 4.67, @user.reload.ranking_score, 0.01
  end

  test "refresh_rankings! keeps going when one user fails" do
    @user.update_column(:ranking_month, nil)
    failing_id = @other.id
    User.define_method(:refresh_ranking!) do
      raise "boom" if id == failing_id
      super()
    end

    assert_nothing_raised { User.refresh_rankings! }
    assert_equal Date.current.beginning_of_month, @user.reload.ranking_month
  ensure
    User.remove_method(:refresh_ranking!)
  end

  # scopes -----------------------------

  test "ranked orders by score and skips unranked users" do
    @user.update!(ranking_score: 20)
    @other.update!(ranking_score: 0)

    assert_equal [@user], User.ranked.to_a
  end

  test "friends_ranking includes mutual friends and self ordered by score" do
    @user.update!(ranking_score: 10)
    @other.update!(ranking_score: 50)

    assert_equal [@other, @user], @user.friends_ranking.to_a
  end

  test "friends_ranking excludes users that are not mutual friends" do
    follows(:two).destroy

    assert_equal [@user], @user.friends_ranking.to_a
  end

  # position ---------------------------

  test "position_in_ranking counts users with a higher score" do
    @user.update!(ranking_score: 10)
    @other.update!(ranking_score: 50)

    assert_equal 2, @user.position_in_ranking(User.ranked)
    assert_equal 1, @other.position_in_ranking(User.ranked)
  end

  test "position_in_ranking is relative to the ranking it is asked of" do
    @user.update!(ranking_score: 10)
    @other.update!(ranking_score: 50)
    User.create!(name: "top", email: "top@example.com", password: "Secret1*3*5*", ranking_score: 90, ranking_month: Date.current.beginning_of_month)

    assert_equal 3, @user.position_in_ranking(User.ranked)
    assert_equal 2, @user.position_in_ranking(@user.friends_ranking)
  end

  test "position_in_ranking ignores friends whose aggregate is from another month" do
    @user.update!(ranking_score: 10)
    @other.update!(ranking_score: 95, ranking_month: Date.current.prev_month.beginning_of_month)

    assert_equal 1, @user.position_in_ranking(@user.friends_ranking)
  end

  test "ranked? reflects a positive score" do
    @user.update!(ranking_score: 0)
    assert_not @user.ranked?

    @user.update!(ranking_score: 1)
    assert @user.ranked?
  end

  test "previous month and future completions do not contribute and history is preserved" do
    previous = @user.sheet_completions.create!(sheet: sheets(:one), completed_at: 1.month.ago)
    future = @user.sheet_completions.create!(sheet: sheets(:one), completed_at: 1.day.from_now)

    assert_in_delta 4.67, @user.reload.ranking_score, 0.01
    assert_equal 0, @user.current_streak
    assert_equal 1.month.ago, previous.reload.completed_at
    assert_equal 1.day.from_now, future.reload.completed_at
  end

  test "month and year rollover logically reset persisted scores without a job" do
    [Time.zone.local(2026, 9, 30, 23, 59, 59), Time.zone.local(2026, 12, 31, 23, 59, 59)].each do |time|
      travel_to time
      @user.sheet_completions.create!(sheet: sheets(:one))
      assert @user.reload.ranked?
      count = @user.sheet_completions.count

      travel 1.second

      assert_equal 0, @user.ranking_score
      assert_equal 0, @user.current_streak
      assert_empty User.ranked
      assert @user.friends_ranking.all? { |user| user.ranking_score.zero? }
      assert_equal count, @user.sheet_completions.count

      @user.sheet_completions.create!(sheet: sheets(:one))
      assert_in_delta 3.33, @user.reload.ranking_score, 0.01
      assert_equal 1, @user.current_streak
    end
  end

  test "UTC midnight does not split a local day or start a new month" do
    travel_to Time.zone.local(2026, 9, 30, 23, 30)
    @user.sheet_completions.destroy_all
    @user.sheet_completions.create!(sheet: sheets(:one), completed_at: Time.zone.local(2026, 9, 30, 20, 30))
    @user.sheet_completions.create!(sheet: sheets(:one))

    assert_equal Date.new(2026, 10, 1), Time.current.utc.to_date
    assert_equal Date.new(2026, 9, 1), @user.reload.ranking_month
    assert_in_delta 3.33, @user.ranking_score, 0.01
    assert_equal 1, @user.current_streak
    assert_equal [@user], User.ranked.to_a
  end

  test "different local days in the same UTC day advance the streak" do
    travel_to Time.zone.local(2026, 9, 16, 1)
    @user.sheet_completions.destroy_all
    @user.sheet_completions.create!(sheet: sheets(:one), completed_at: Time.zone.local(2026, 9, 15, 23))
    @user.sheet_completions.create!(sheet: sheets(:one))

    assert_equal 2, @user.reload.current_streak
    assert_in_delta 6.67, @user.ranking_score, 0.01
  end

  test "repeated rounds and ranking refreshes do not duplicate points" do
    sheets(:one).complete!
    score = @user.reload.ranking_score

    3.times { sheets(:one).complete! }
    2.times { User.refresh_rankings! }

    assert_equal score, @user.reload.ranking_score
    assert_equal 3, @user.current_streak
  end

  test "friends reuse global order and id tie breaker" do
    @user.update!(ranking_score: 10)
    @other.update!(ranking_score: 10)

    ordered_users = [@user, @other].sort_by(&:id)
    assert_equal ordered_users, User.ranked.to_a
    assert_equal ordered_users, @user.friends_ranking.to_a
    ordered_users.each_with_index do |user, index|
      assert_equal index + 1, user.position_in_ranking(User.ranked)
    end
  end

  test "friends with old scores are displayed at zero behind current scores" do
    @other.update!(ranking_score: 100, ranking_month: Date.current.prev_month.beginning_of_month)

    friends = @user.friends_ranking.to_a
    assert_equal [@user, @other], friends
    assert_equal 0, friends.last.ranking_score
    assert_equal 1, @user.position_in_ranking(User.ranked)
    assert_equal [@user], User.ranked.to_a
  end

  test "friends exclude both directions of one way follows and users without relationships" do
    follows(:one).destroy!
    assert_equal [@user], @user.friends_ranking.to_a

    follows(:two).destroy!
    assert_equal [@user], @user.friends_ranking.to_a
  end

  test "the score does not drift during the last day of a 31 day month" do
    @user.sheet_completions.destroy_all
    travel_to Time.zone.local(2026, 10, 31, 8)
    [ Time.zone.local(2026, 10, 1, 9), Time.zone.local(2026, 10, 2, 9) ].each do |time|
      @user.sheet_completions.create!(sheet: sheets(:one), completed_at: time)
    end
    morning = @user.reload.ranking_score

    travel_to Time.zone.local(2026, 10, 31, 20)
    @user.refresh_ranking!

    assert_in_delta 4.67, morning, 0.01
    assert_equal morning, @user.reload.ranking_score
  end

  test "consistency is capped so a 31 day month does not exceed the maximum score" do
    @user.sheet_completions.destroy_all
    travel_to Time.zone.local(2026, 10, 31, 23)
    (0..30).each { |day| @user.sheet_completions.create!(sheet: sheets(:one), completed_at: day.days.ago) }
    @user.refresh_ranking!

    assert_equal 31, @user.sheet_completions.active_days.size
    assert_equal 100, @user.reload.ranking_score
  end

  test "legacy aggregates without a month are rebuilt from existing history" do
    @user.update_columns(ranking_month: nil, ranking_score: 100)
    assert_equal 0, @user.reload.ranking_score

    User.refresh_rankings!

    assert_in_delta 4.67, @user.reload.ranking_score, 0.01
    assert_equal Date.current.beginning_of_month, @user.ranking_month
  end
end
