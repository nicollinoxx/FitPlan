require "test_helper"

class FollowTest < ActiveSupport::TestCase
  setup do
    @user  = users(:lazaro_nixon)
    @other = users(:lazaro)
  end

  test "following? returns true when following" do
    assert @user.following?(@other)
  end

  test "following? returns false when not following" do
    follows(:one).destroy
    assert_not @user.following?(@other)
  end

  test "follow! creates a follow record" do
    follows(:one).destroy

    assert_difference "Follow.count", 1 do
      @user.follow!(followed: @other)
    end
  end

  test "follow! is idempotent" do
    assert_no_difference "Follow.count" do
      @user.follow!(followed: @other)
    end
  end

  test "unfollow! destroys the follow record" do
    assert_difference "Follow.count", -1 do
      @user.unfollow!(followed: @other)
    end
  end

  test "cannot follow self" do
    follow = Follow.new(follower: @user, followed: @user)

    assert_not follow.valid?
    assert_includes follow.errors[:follower_id], "can't follow yourself"
  end

  test "follower and followed pair must be unique" do
    follow = Follow.new(follower: @user, followed: @other)

    assert_not follow.valid?
  end

  test "unseen_followers? returns true when there are unseen followers" do
    assert @user.unseen_followers?
  end

  test "mark_followers_as_seen! clears unseen followers" do
    @user.mark_followers_as_seen!
    assert_not @user.unseen_followers?
  end

  test "followers includes users who follow the user" do
    assert_includes @user.followers, @other
  end

  test "followings includes users the user follows" do
    assert_includes @user.followings, @other
  end
end
