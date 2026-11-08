require "application_system_test_case"

class Identity::EmailsTest < ApplicationSystemTestCase
  setup do
    @user = sign_in_as(users(:lazaro_nixon))
  end

  test "updating the email" do
    visit identity_settings_url

    click_on t("identity.settings.show.settings.change_email")

    fill_in :email, with: "new_email@hey.com"
    fill_in :password_challenge, with: "Secret1*3*5*"
    click_on t("save")

    assert_text t("notice.email.update")
  end

  test "sending a verification email" do
    @user.update! verified: false
    visit identity_settings_url

    click_on t("identity.settings.show.settings.change_email")
    click_on t("identity.emails.edit.send_verification_email")

    assert_text t("notice.email_verification.create")
  end
end
