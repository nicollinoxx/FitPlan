require "application_system_test_case"

class RegistrationsTest < ApplicationSystemTestCase
  test "signing up" do
    visit sign_up_url

    fill_in :name, with: "Lazaro Nixon"
    fill_in :email, with: "lazaronixon@hey.com"
    fill_in :password, with: "Secret6*4*2*"
    fill_in :password_confirmation, with: "Secret6*4*2*"
    click_on t("registrations.new.submit")

    assert_selector "h1", text: t("sheets.index.title")
  end
end
