require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  setup do
    @user = users(:lazaro_nixon)
  end

  test "visiting the index" do
    sign_in_as @user

    visit identity_settings_url

    click_on t("identity.settings.show.session.collection_sessions")
    assert_selector "h1", text: t("sessions.index.title")
  end

  test "signing in" do
    sign_in_as @user
  end

  test "signing out" do
    sign_in_as @user
    visit sessions_url

    click_on t("destroy"), match: :first
    confirm_dialog

    assert_text t("notice.session.destroy")
  end
end
