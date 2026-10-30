require "test_helper"

class RecommendationChannelTest < ActionCable::Channel::TestCase
  test "streams only what is meant for the signed in user" do
    stub_connection current_user: users(:lazaro_nixon)
    subscribe

    assert subscription.confirmed?
    assert_has_stream_for users(:lazaro_nixon)
  end
end
