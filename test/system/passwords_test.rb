require "application_system_test_case"

class PasswordsTest < ApplicationSystemTestCase
  setup do
    @user = sign_in_as(users(:lazaro_nixon))
  end

  test "updating the password" do
    visit identity_settings_url

    click_on t("identity.settings.show.settings.change_password")

    fill_in :password_challenge, with: "Secret1*3*5*"
    fill_in :password, with: "Secret6*4*2*"
    fill_in :password_confirmation, with: "Secret6*4*2*"
    click_on t("save")

    assert_text t("notice.password.update")
  end
end
