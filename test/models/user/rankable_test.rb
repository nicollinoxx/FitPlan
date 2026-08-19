require "test_helper"

class User::RankableTest < ActiveSupport::TestCase
  setup do
    @user  = users(:lazaro_nixon)
    @other = users(:lazaro)
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

  test "ranking_position counts users with a higher score" do
    @user.update!(ranking_score: 10)
    @other.update!(ranking_score: 50)

    assert_equal 2, @user.ranking_position
    assert_equal 1, @other.ranking_position
  end

  test "ranked? reflects a positive score" do
    @user.update!(ranking_score: 0)
    assert_not @user.ranked?

    @user.update!(ranking_score: 1)
    assert @user.ranked?
  end
end
