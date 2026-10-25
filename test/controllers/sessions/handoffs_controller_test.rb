require "test_helper"

class Sessions::HandoffsControllerTest < ActionDispatch::IntegrationTest
  APP = { "User-Agent" => "FitPlan Hotwire Native Android" }

  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(provider: "google_oauth2", uid: "123", info: { email: users(:lazaro_nixon).email, name: "Lazaro" })
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  test "the app signs in through google in a custom tab and gets the session when shown again" do
    with_memory_cache do
      get sign_in_url, headers: APP
      tab = open_session

      tab.get handoff_link_for("google_oauth2")
      tab.assert_select "form[action='/auth/google_oauth2'][data-controller='auto-submit']"

      tab.get "/auth/google_oauth2/callback"
      tab.assert_select "h1", I18n.t("sessions.handed_off.title")
      assert_nil tab.cookies[:session_token]

      get sign_in_url, headers: APP
      assert_redirected_to sheets_url(format: :html)
    end
  end

  test "whichever page the app is back on claims the sign in" do
    with_memory_cache do
      get sign_in_url, headers: APP
      tab = open_session
      tab.get handoff_link_for("google_oauth2")

      get welcome_url, headers: APP
      assert_select "body[data-controller='refresh-on-return']"

      tab.get "/auth/google_oauth2/callback"

      get welcome_url, headers: APP
      assert_redirected_to sheets_url(format: :html)
    end
  end

  test "only the app that started the sign in can claim it" do
    with_memory_cache do
      get sign_in_url, headers: APP
      link = handoff_link_for("google_oauth2")

      tab = open_session
      tab.get link
      tab.get "/auth/google_oauth2/callback"

      stranger = open_session
      stranger.get sign_in_url, headers: APP
      stranger.assert_response :success
      assert_nil stranger.cookies[:session_token]
    end
  end

  test "the browser keeps posting straight to the provider" do
    get sign_in_url

    assert_select "form[action='/auth/google_oauth2']"
    assert_select "a[href*='/handoff']", false
  end

  private

    def handoff_link_for(provider)
      css_select("a[href*='/auth/#{provider}/handoff']").first["href"]
    end
end
