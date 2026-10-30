require "test_helper"

class OpenRouter::PkceTest < ActiveSupport::TestCase
  test "challenge is the base64url SHA-256 of the verifier, as RFC 7636 asks" do
    pkce = OpenRouter::Pkce.new("state")

    assert_equal Base64.urlsafe_encode64(Digest::SHA256.digest(pkce.verifier), padding: false), authorize_query(pkce)["code_challenge"]
  end

  test "authorize url carries the callback, the challenge method and the state" do
    query = authorize_query(OpenRouter::Pkce.new("state"))

    assert_equal "http://localhost:3000/callback", query["callback_url"]
    assert_equal "S256", query["code_challenge_method"]
    assert_equal "state", query["state"]
  end

  test "the verifier comes back from the state alone and never travels in the url" do
    pkce = OpenRouter::Pkce.new("state")

    assert_equal pkce.verifier, OpenRouter::Pkce.new("state").verifier
    assert_not_equal pkce.verifier, OpenRouter::Pkce.new("other state").verifier
    assert_not_includes pkce.authorize_url("http://localhost:3000/callback"), pkce.verifier
  end

  private

    def authorize_query(pkce)
      Rack::Utils.parse_query(URI(pkce.authorize_url("http://localhost:3000/callback")).query)
    end
end
