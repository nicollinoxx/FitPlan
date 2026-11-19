require "test_helper"

class SecurityHeadersTest < ActionDispatch::IntegrationTest
  test "sends a content security policy with a script nonce" do
    get welcome_url

    policy = response.headers["Content-Security-Policy"]
    assert_match "default-src 'self'", policy
    assert_match "object-src 'none'", policy
    assert_match(/script-src 'self' 'nonce-[^']+'/, policy)
  end

  test "sends the standard permissions policy header" do
    get welcome_url

    assert_match "camera=()", response.headers["Permissions-Policy"]
    assert_nil response.headers["Feature-Policy"]
  end
end
