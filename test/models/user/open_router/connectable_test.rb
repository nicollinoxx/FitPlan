require "test_helper"

class User::OpenRouter::ConnectableTest < ActiveSupport::TestCase
  setup do
    @user = users(:lazaro_nixon)
  end

  test "connecting stores the key encrypted" do
    @user.connect_open_router!("sk-or-secret")

    assert @user.reload.open_router_connected?
    assert_equal "sk-or-secret", @user.open_router_key
    assert_not_includes @user.ciphertext_for(:open_router_key), "sk-or-secret"
  end

  test "disconnecting forgets the key and the chosen model" do
    @user.update!(open_router_key: "sk-or-secret", open_router_model: "b/free:free")
    @user.disconnect_open_router!

    assert_not @user.reload.open_router_connected?
    assert_nil @user.open_router_model
  end

  test "the free models router is the preferred model until one is chosen" do
    assert_equal "openrouter/free", @user.preferred_open_router_model

    @user.open_router_model = "b/free:free"
    assert_equal "b/free:free", @user.preferred_open_router_model
  end

  test "free requests come from the user's own key" do
    @user.connect_open_router!("sk-or-secret")
    used_key = nil

    stub_singleton(OpenRouter::Client, :key, ->(key) { used_key = key; { "free_model_daily_requests" => { "used" => 3, "limit" => 50, "remaining" => 47 } } }) do
      assert_equal 47, @user.open_router_free_requests["remaining"]
    end

    assert_equal "sk-or-secret", used_key
  end
end
