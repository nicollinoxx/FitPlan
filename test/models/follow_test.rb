require "test_helper"

class FollowTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActionCable::TestHelper

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

  test "user_online? returns true when cache key exists" do
    with_memory_cache do |cache|
      cache.write("user_online:#{@other.id}", true)
      follow = Follow.new(follower: @user, followed: @other)
      assert follow.send(:user_online?)
    end
  end

  test "user_online? returns false when cache key is absent" do
    follow = Follow.new(follower: @user, followed: @other)
    assert_not follow.send(:user_online?)
  end

  test "broadcasts to followed user when online" do
    follows(:one).destroy
    with_memory_cache do |cache|
      cache.write("user_online:#{@other.id}", true)
      assert_broadcasts("follow_notifications_#{@other.id}", 1) do
        @user.follow!(followed: @other)
      end
    end
  end

  test "sends email to followed user when offline" do
    follows(:one).destroy
    assert_enqueued_emails 1 do
      @user.follow!(followed: @other)
    end
  end
end
