require "test_helper"

class ClientIpTest < ActionDispatch::IntegrationTest
  KAMAL_PROXY = "172.18.0.5"

  setup { @user = users(:lazaro_nixon) }

  test "records the visitor's address, not Cloudflare's edge" do
    sign_in_through "203.0.113.7, 172.71.2.156"

    assert_equal "203.0.113.7", last_session_ip
  end

  test "records the visitor's address over IPv6 edges too" do
    sign_in_through "2001:db8::7, 2606:4700::1"

    assert_equal "2001:db8::7", last_session_ip
  end

  test "a request that skips Cloudflare can't spoof its address" do
    sign_in_through "1.2.3.4, 198.51.100.9"

    assert_equal "198.51.100.9", last_session_ip
  end

  private
    def sign_in_through(forwarded_for)
      post sign_in_url, params: { email: @user.email, password: "Secret1*3*5*" },
                        headers: { "X-Forwarded-For" => forwarded_for },
                        env: { "REMOTE_ADDR" => KAMAL_PROXY }
    end

    def last_session_ip
      @user.sessions.order(:created_at).last.ip_address
    end
end
