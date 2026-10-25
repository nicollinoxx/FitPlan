require "test_helper"

class OpenRouter::ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as(users(:lazaro_nixon))
  end

  test "sends the user to OpenRouter with a PKCE challenge" do
    post open_router_connection_url

    assert_redirected_to %r{\Ahttps://openrouter\.ai/auth\?}
    assert_equal "S256", authorize_query["code_challenge_method"]
    assert_equal callback_open_router_connection_url, authorize_query["callback_url"]
  end

  test "stores the key OpenRouter hands back for the code" do
    post open_router_connection_url
    exchanged = nil

    stub_singleton(OpenRouter::Client, :exchange_code, ->(code:, verifier:) { exchanged = [ code, verifier ]; "sk-or-new" }) do
      get callback_open_router_connection_url(code: "code", state: authorize_query["state"])
    end

    assert_redirected_to new_recommendation_url
    assert_equal "sk-or-new", @user.reload.open_router_key
    assert_equal "code", exchanged.first
    assert exchanged.last.present?
  end

  test "ignores a callback whose state does not match" do
    post open_router_connection_url

    get callback_open_router_connection_url(code: "code", state: "forged")

    assert_redirected_to new_recommendation_url
    assert_not @user.reload.open_router_connected?
  end

  test "ignores a callback that was never started here" do
    get callback_open_router_connection_url(code: "code", state: "state")

    assert_not @user.reload.open_router_connected?
  end

  test "disconnecting forgets the key" do
    @user.connect_open_router!("sk-or-test")

    delete open_router_connection_url

    assert_redirected_to new_recommendation_url
    assert_not @user.reload.open_router_connected?
  end

  private

    def authorize_query
      Rack::Utils.parse_query(URI(response.location).query)
    end
end
