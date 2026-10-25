require "test_helper"

class OpenRouter::PkceTest < ActiveSupport::TestCase
  test "challenge is the base64url SHA-256 of the verifier from RFC 7636" do
    pkce = OpenRouter::Pkce.new(verifier: "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")

    assert_equal "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM", authorize_query(pkce)["code_challenge"]
  end

  test "authorize url carries the callback, the challenge method and the state" do
    query = authorize_query(OpenRouter::Pkce.new(verifier: "verifier", state: "state"))

    assert_equal "http://localhost:3000/callback", query["callback_url"]
    assert_equal "S256", query["code_challenge_method"]
    assert_equal "state", query["state"]
  end

  test "each flow gets its own verifier and state" do
    assert_not_equal OpenRouter::Pkce.new.verifier, OpenRouter::Pkce.new.verifier
    assert_not_equal OpenRouter::Pkce.new.state, OpenRouter::Pkce.new.state
  end

  private

    def authorize_query(pkce)
      Rack::Utils.parse_query(URI(pkce.authorize_url("http://localhost:3000/callback")).query)
    end
end
