require "test_helper"

class OpenRouter::ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
  end

  test "stores the key OpenRouter hands back and returns to the form" do
    sign_in_as(@user)

    with_exchanged_key("sk-or-new") { get callback_open_router_connection_url(code: "code", state: state_for(@user)) }

    assert_redirected_to new_recommendation_url
    assert_equal "sk-or-new", @user.reload.open_router_key
  end

  test "connects from a Custom Tab, where nobody is signed in" do
    with_exchanged_key("sk-or-new") { get callback_open_router_connection_url(code: "code", state: state_for(@user)) }

    assert_response :success
    assert_select "h1", I18n.t("open_router.connections.callback.title")
    assert_equal "sk-or-new", @user.reload.open_router_key
  end

  test "exchanges the code with the verifier derived from the state" do
    state = state_for(@user)
    exchanged = nil

    stub_singleton(OpenRouter::Client, :exchange_code, ->(code:, verifier:) { exchanged = verifier; "sk-or-new" }) do
      get callback_open_router_connection_url(code: "code", state: state)
    end

    assert_equal OpenRouter::Pkce.new(state).verifier, exchanged
  end

  test "ignores a forged or expired state" do
    get callback_open_router_connection_url(code: "code", state: "forged")
    assert_not @user.reload.open_router_connected?

    state = state_for(@user)
    travel 11.minutes do
      get callback_open_router_connection_url(code: "code", state: state)
    end
    assert_not @user.reload.open_router_connected?
  end

  test "disconnecting forgets the key" do
    sign_in_as(@user).connect_open_router!("sk-or-test")

    delete open_router_connection_url

    assert_redirected_to new_recommendation_url
    assert_not @user.reload.open_router_connected?
  end

  private

    def state_for(user)
      Rack::Utils.parse_query(URI(user.open_router_authorize_url("http://www.example.com/callback")).query)["state"]
    end

    def with_exchanged_key(key, &)
      stub_singleton(OpenRouter::Client, :exchange_code, ->(**) { key }, &)
    end
end
