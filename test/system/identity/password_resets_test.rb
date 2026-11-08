require "application_system_test_case"

class Identity::PasswordResetsTest < ApplicationSystemTestCase
  setup do
    @user = users(:lazaro_nixon)
    @sid = @user.generate_token_for(:password_reset)
  end

  test "sending a password reset email" do
    visit sign_in_url
    click_on t("sessions.new.link_forgot_password")

    fill_in :email, with: @user.email
    click_on t("identity.password_resets.new.send_reset_email")

    assert_text t("notice.password_reset.create")
  end

  test "updating password" do
    visit edit_identity_password_reset_url(sid: @sid)

    fill_in :password, with: "Secret6*4*2*"
    fill_in :password_confirmation, with: "Secret6*4*2*"
    click_on t("save")

    assert_text t("notice.password_reset.update")
  end
end
