require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  test "should get index" do
    sign_in_as @user

    get sessions_url
    assert_response :success
  end

  test "should get new" do
    get sign_in_url
    assert_response :success
  end

  test "should sign in" do
    post sign_in_url, params: { email: @user.email, password: "Secret1*3*5*" }

    get root_url
    assert_response :success
  end

  test "should not sign in with wrong credentials" do
    post sign_in_url, params: { email: @user.email, password: "SecretWrong1*3" }

    assert_redirected_to sign_in_url(email_hint: @user.email)
    assert_equal "Email or password is incorrect", flash[:notice]

    follow_redirect!
    assert_response :success
  end

  test "should sign out" do
    sign_in_as @user

    delete session_url(@user.sessions.last)
    assert_redirected_to sessions_url

    follow_redirect!
    assert_redirected_to welcome_url
  end

  test "should sign in with google" do
    OmniAuth.config.mock_auth[:google_oauth2] = google_auth_hash(email: @user.email, name: @user.name)

    assert_no_difference -> { User.count } do
      get "/auth/google_oauth2/callback"
    end

    assert_response :success
    assert_select "[data-controller=redirect][data-redirect-url-value=?]", root_path
    assert_equal "123", @user.reload.uid

    get root_url
    assert_response :success
  end

  test "should sign up with google" do
    OmniAuth.config.mock_auth[:google_oauth2] = google_auth_hash(email: "new@hotmail.com", name: "New User")

    assert_difference -> { User.count }, 1 do
      get "/auth/google_oauth2/callback"
    end

    assert_response :success
    assert User.find_by(email: "new@hotmail.com").verified?

    get root_url
    assert_response :success
  end

  test "should attach the google picture as avatar" do
    OmniAuth.config.mock_auth[:google_oauth2] = google_auth_hash(email: @user.email, name: @user.name, image: "https://lh3.googleusercontent.com/photo")

    stub_uri_open(fixture_file_upload("avatar.png", "image/png")) do
      get "/auth/google_oauth2/callback"
    end

    assert @user.reload.avatar.attached?
  end

  test "should keep the current avatar when signing in with google" do
    @user.avatar.attach(fixture_file_upload("avatar.png", "image/png"))
    OmniAuth.config.mock_auth[:google_oauth2] = google_auth_hash(email: @user.email, name: @user.name, image: "https://lh3.googleusercontent.com/photo")

    stub_uri_open(fixture_file_upload("sample_video.mp4", "video/mp4")) do
      get "/auth/google_oauth2/callback"
    end

    assert_equal "avatar.png", @user.reload.avatar.filename.to_s
  end

  test "should not sign in with google without an email" do
    OmniAuth.config.mock_auth[:google_oauth2] = google_auth_hash(email: nil, name: "New User")

    get "/auth/google_oauth2/callback"

    assert_response :unprocessable_entity
  end

  test "should not sign in with google when the provider fails" do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    get "/auth/google_oauth2/callback"
    follow_redirect!

    assert_redirected_to sign_in_url
    assert_equal "Could not sign in with Google", flash[:notice]
  end

  private
    def google_auth_hash(email:, name:, image: nil)
      OmniAuth::AuthHash.new(provider: "google_oauth2", uid: "123", info: { email: email, name: name, image: image })
    end
end
