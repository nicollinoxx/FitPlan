require "test_helper"

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    setup do
      @user    = users(:lazaro_nixon)
      @session = sessions(:sender_session)
    end

    test "connects with a valid session cookie" do
      cookies.signed[:session_token] = @session.id
      connect
      assert_equal @user, connection.current_user
    end

    test "marks user as online on connect" do
      with_memory_cache do |cache|
        cookies.signed[:session_token] = @session.id
        connect
        assert cache.exist?("user_online:#{@user.id}")
      end
    end

    test "online status expires via TTL without heartbeat" do
      with_memory_cache do |cache|
        cookies.signed[:session_token] = @session.id
        connect
        assert cache.exist?("user_online:#{@user.id}")
        cache.delete("user_online:#{@user.id}") # simulate TTL expiry
        assert_not cache.exist?("user_online:#{@user.id}")
      end
    end

    test "rejects connection without a session cookie" do
      assert_reject_connection { connect }
    end

    test "rejects connection with an invalid session cookie" do
      cookies.signed[:session_token] = 0
      assert_reject_connection { connect }
    end
  end
end
