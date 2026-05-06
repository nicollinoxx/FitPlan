require "test_helper"

class PresenceChannelTest < ActionCable::Channel::TestCase
  setup do
    @user = users(:lazaro_nixon)
    stub_connection current_user: @user
  end

  test "subscribes successfully" do
    subscribe
    assert subscription.confirmed?
  end

  test "heartbeat renews online status in cache" do
    with_memory_cache do |cache|
      subscribe
      perform :heartbeat
      assert cache.exist?("user_online:#{@user.id}")
    end
  end
end
